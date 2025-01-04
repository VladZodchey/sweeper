from random import randint
from enum import Enum

# TODO :: Сделать enum для символов для быстрой замены
# TODO :: Сделать границы клеток
# TODO :: Раскрасить текст


class Modes(Enum):  # Enum для режимов (Можно было бы обойтись и без него)
    flag = 0  # пометить флагом
    dig = 1   # подкопать клетку
    undo = 2  # отменить расположение флага


class Sweeper:
    def __init__(self, width: int, height: int, probability: int) -> None:  # Вводные настройки
        self.width  =  width
        self.height =  height
        self.field  =  [['.'] * height for _ in range(width)]
        self.plan   =  [['#'] * height for _ in range(width)]
        self.game   =  True
        self.prob   =  probability
        self.mines  =  0
        self.flags  =  0


    # ИГРА


    def main(self) -> None:  # Основной цикл игры
        self.field = self.numerated(self.generated(self.prob))
        print('Ввод осуществляется так: первым идёт режим -- d для подкопа клетки, f для флага и u для убирания флага.')
        print('Потом идёт номер ряда по вертикали, а потом номер столбца по горизонтали.')
        print('Постарайтесь не взорваться!')
        while self.game:
            if self.win():
                print('\n'.join(['\t'.join([cell if cell != '*' else '♥' for cell in row]) for row in self.field]))
                print('Вы выиграли!')
                exit()
            mode, x, y = self.ask()
            self.think(mode, x, y)


    def win(self) -> bool:  # Проверка на победную ситуацию
        if self.mines != self.flags: return False
        if not all(['#' not in row for row in self.plan]): return False
        correct = True
        for x in range(self.width):
            for y in range(self.height):
                if (self.plan[x][y] == 'P') != (self.field[x][y] == '*'):
                    correct = False
        return correct


    def ask(self) -> any:  # Взаимодействие с пользователем
        # ... вывести клетки ...
        merged = [[''] * self.height for _ in range(self.width)]
        for x in range(self.width):
            for y in range(self.height):
                merged[x][y] = self.plan[x][y] if self.plan[x][y] != '' else self.field[x][y]
        print('\n'.join([f'{str(index + 1)}\t' + '\t'.join([cell for cell in row]) for index, row in enumerate(merged)]))
        print(' \t' + '\t'.join(str(i) for i in range(1, self.height + 1)))
        print(f'Флагов: {self.flags}/{self.mines}')
        # ... спросить ...
        while True:
            try:
                decision = input('Введите режим и координаты по горизонтали и вертикали: ').split()
                assert len(decision) == 3
                assert self.width >= int(decision[1]) >= 1
                assert self.height >= int(decision[2]) >= 1

                match decision[0].lower():
                    case 'f': mode = Modes.flag
                    case 'p': mode = Modes.flag
                    case 'd': mode = Modes.dig
                    case 'u': mode = Modes.undo
                    case _: raise AssertionError
                x = int(decision[1]) - 1
                y = int(decision[2]) - 1
                break
            except AssertionError:
                print('Неверный ввод!')
                continue
        # noinspection PyUnboundLocalVariable
        return mode, x, y


    def think(self, mode: Modes, x: int, y: int) -> None:  # Осуществляет логику игры
        match mode:
            case Modes.dig:
                if self.is_mine(x, y):
                    for x in range(self.width):
                        for y in range(self.height):
                            self.plan[x][y] = ''
                    print('\n'.join(['\t'.join([cell for cell in row]) for row in self.field]))
                    print('Игра окончена :(')
                    self.game = False
                elif self.plan[x][y] == '':
                    print('Зона уже открыта.')
                else:
                    self.reveal_cells((x, y))
            case Modes.flag:
                if self.plan[x][y] == '#':
                    self.plan[x][y] = 'P'
                    self.flags += 1
                else:
                    print('Зона уже открыта.')
            case Modes.undo:
                if self.plan[x][y] == 'P':
                    self.plan[x][y] = '#'
                    self.flags -= 1
                else:
                    print('Здесь нет флага!')


    # ПРОВЕРКИ


    def is_mine(self, x: int, y: int) -> bool:  # Мина?
        return self.field[x][y] == '*'

    def is_number(self, x: int, y: int) -> bool:  # Число?
        return self.field[x][y] in '12345678'

    def is_flag(self, x: int, y: int) -> bool:  # Флажок?
        return self.plan[x][y] == 'P'


    # ГЕНЕРАЦИЯ


    def generated(self, probability : int) -> list:  # Разложение мин
        populated = self.field.copy()
        for x in range(self.width):
            for y in range(self.height):
                if randint(1, 100) <= probability:
                    populated[x][y] = '*'
                    self.mines += 1
        return populated


    def numerated(self, array: list) -> list:  # Расстановка цифр
        numbered = array.copy()
        for x in range(self.width):
            for y in range(self.height):
                if array[x][y] != '*':
                    count = 0
                    for coord in self.surrounding((x, y)):
                        if self.field[coord[0]][coord[1]] == '*':
                            count += 1
                    numbered[x][y] = str(count) if count != 0 else '.'
        return numbered


    # СЛУЖБЫ


    def reveal_cells(self, coord: (int, int,)) -> None:  # Вывод незанятых клеток
        revealed = []
        to_reveal = [coord]
        while len(to_reveal) != 0:
            if self.is_flag(to_reveal[0][0], to_reveal[0][1]):
                self.flags += 1
            self.plan[to_reveal[0][0]][to_reveal[0][1]] = ''
            revealed.append(to_reveal[0])
            if not self.is_number(to_reveal[0][0], to_reveal[0][1]):
                for i in self.surrounding(to_reveal[0]):
                    if i not in revealed:
                        if i not in to_reveal:
                            to_reveal.append(i)
            to_reveal.pop(0)



    def surrounding(self, coords: (int, int,)) -> list:  # Служебный метод получения клеток вокруг
        cells = []
        for x in range(coords[0] - 1, coords[0] + 2):
            for y in range(coords[1] - 1, coords[1] + 2):
                if (x, y) != coords:
                    #print((x, y,))
                    if self.width - 1 >= x >= 0 and self.height - 1 >= y >=0:
                        cells.append((x, y,))
        return cells


if __name__ == '__main__':  # Инициализация
    print('Привет. Это простой сапёр, который я сделал за 6-8 часов вместо того, что бы заниматься действительно полезными делами.')
    while True:
        try:
            w = int(input('Высота поля: '))
            h = int(input('Ширина поля: '))
            d = int(input('% мин: '))
            assert 1000 >= w >= 1
            assert 1000 >= h >= 1
            assert 100 >= d >= 1
            break
        except AssertionError:
            print('Неверный ввод!')
    #noinspection -- PyCharm считает, что переменные выше могут быть не определены.
    app = Sweeper(w, h, d)
    app.main()