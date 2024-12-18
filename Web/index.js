const rows = 8; // Рядов (y)
const cols = 8; // Столбцов (x)
const prob = 10; // Процентаж мин

const board = document.getElementById('board')
const goal = document.getElementById('goal')

const colors = [
    'white',
    'green',
    'aqua',
    'brown',
    'blue',
    'deeppink',
    'gold',
    'indigo',
    'midnightblue'
]

var field = []   // Поле с минами
var plan = []    // Как оно выглядит для игрока.
var running = true
var started = false

var mines = 0;
var flags = 0;



// Создаёт массивы
function initialize() {
    for (let x = 0; x < cols; x++) {
        field[x] = []
        plan[x] = []
        for (let y = 0; y < rows; y++) {
            field[x][y] = '.'
            plan[x][y] = '#'
        }
    }
}

// Заполняет поле минами.
function generate() {
    for (let x = 0; x < cols; x++) {
        for (let y = 0; y < rows; y++) {
            if (Math.random() < prob / 100) {
                field[x][y] = '*'
                mines++;
            } 
        }
    }
}

// Расставляет циферки.
function numerate() {
    for (let x = 0; x < cols; x++) {
        for (let y = 0; y < rows; y++) {
            if (field[x][y] == '*') {continue}
            let surround = surrounding(x, y)
            let count = 0 
            for (let i = 0; i < surround.length; i++) {
                let cell_x = surround[i][0]
                let cell_y = surround[i][1]
                if (field[cell_x][cell_y] == '*') {
                    count++
                }
            }
            
            if (count > 0) {
                field[x][y] = count.toString()
            }
        }
    }
}

// Служебная функция, возвращает массив клеток вокруг.
function surrounding(pivot_x, pivot_y) {
    let cells = []
    for (let x = pivot_x - 1; x < pivot_x + 2; x++) {
        for (let y = pivot_y - 1; y < pivot_y + 2; y++) {
            //console.log(x, y)
            if (x != pivot_x || y != pivot_y) {
                //console.log('Not pivot')
                if ((x >= 0 && x < cols) && (y >= 0 && y < rows)) {
                    cells.push([x, y])
                }
            }
        }
    }
    return cells
}

// Служебная функция, открывает клетки.
function reveal(x, y) { 
    let revealed = []
    let to_reveal = [[x, y]]
    while (to_reveal.length != 0) {
        let revealing = to_reveal[0]
        if (plan[to_reveal[0][0]][to_reveal[0][1]] == 'P') {
            flags++
        }
        plan[revealing[0]][revealing[1]] = ''
        revealed.push(revealing)
        if (field[revealing[0]][revealing[1]] == '.') {
            //console.log('Thats not a number')
            let surround = surrounding([revealing[0]], [revealing[1]])
            for (let i = 0; i < surround.length; i++) {
                if (!in_array(surround[i], revealed)) {
                    console.log('got to reveal includes')
                    if (!in_array(surround[i], to_reveal)) {
                        console.log('got to revealeD includes')
                        if ('12345678.'.includes(field[surround[i][0]][surround[i][1]])) {
                            to_reveal.push(surround[i])
                        }
                    }
                }
            }
        }
        to_reveal.shift()
    }
}

// Служебная функция, выводит, есть ли элемент в массиве.
function in_array(element, array) {
    for (i = 0; i < array.length; i++) {
        if (equal(element, array[i])) return true
    }
    return false
}

// Служебная функция, выводит, равны ли два массива
function equal(first, second) {
    if (first.length != second.length) return false
    for (let i = 0; i < first.length; i++) {
        if (first[i] != second[i]) return false
    }
    return true
}

// Выводит на экран.
function render() {
    board.innerHTML = ''
    for (let x = 0; x < cols; x++) {
        for (let y = 0; y < rows; y++) {
            const cell = document.createElement('div')
            cell.className = 'cell'
            if (plan[x][y] == '') {
                if (field[x][y] == '*') {
                    cell.style.backgroundColor = 'orangered'
                    cell.style.fontSize = '25px'
                } else if ('12345678'.includes(field[x][y])) {
                    cell.style.color = colors[Number(field[x][y])]
                } else
                {
                    cell.style.backgroundColor = 'white'
                }
                cell.textContent = field[x][y]
            }
            else {
                cell.textContent = plan[x][y]
            }
            if (plan[x][y] == 'P') {
                cell.style.color = 'red'
            }
            cell.addEventListener('click', function() {if (running == true) {dig(x, y); render()}})
            cell.addEventListener('contextmenu', function(ev) {ev.preventDefault(); if (running == true) {flag(x, y); render()}})
            board.appendChild(cell)
        }
        board.appendChild(document.createElement('br'))
    }
    goal.textContent = 'Флагов: ' + flags + '/' + mines
}

// Логика вскапывания. 
function dig(x, y) {
    if (!started) {
        let c = 0
        while (c < 5) {
            if (field[x][y] != '.') {
                mines = 0
                initialize()
                generate()
                numerate()
            }
            else {
                break
            }
            c++
        }
        started = true
    }
    if (field[x][y] == '*' && plan[x][y] != 'P') {
        
        running = false
        for (let x = 0; x < cols; x++) {
            for (let y = 0; y < rows; y++) {
                plan[x][y] = ''
            }
        }
        render()
        alert('Игра окончена!')
    }
    else {
        reveal(x, y)
        render()
    }
}

// Логика установки флага.
function flag(x, y) {
    if (plan[x][y] == 'P') {
        plan[x][y] = '#'
        flags--
    }
    else if (plan[x][y] == '#') {
        plan[x][y] = 'P'
        flags++
    }
    render()
    if (win()) {
        alert('Победа!')
        running = false
        for (let x = 0; x < cols; x++) {
            for (let y = 0; y < rows; y++) {
                plan[x][y] = ''
            }
        }
    }
}

// Логика победы.
function win() {
    if (flags != mines) return false
    for (let x = 0; x < cols; x++) {
        for (let y = 0; y < rows; y++) {
            if ((plan[x][y] == 'P') != (field[x][y] == '*')) {
                return false
            } 
        }
    }
    return true
}

while (mines == 0) {
    mines = 0
    initialize()
    generate()
}
numerate()
render()