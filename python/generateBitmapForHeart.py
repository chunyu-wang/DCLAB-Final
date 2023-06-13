white = 3
black = 1
red   = 2
empty = 0

BITMAP = [
    [empty]*16,
    [empty]*16,
    [0,0,1,1,1,1,1,0,0,1,1,1,1,1,0,0],
    [0,1,1,2,2,2,1,1,1,1,2,2,2,1,1,0],
    [1,1,2,3,3,2,2,1,1,2,2,2,2,2,1,1],
    [1,1,2,3,2,2,2,2,2,2,2,2,2,2,1,1],
    [1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,1],
    [1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,1],
    [0,1,1,2,2,2,2,2,2,2,2,2,2,1,1,0],
    [0,0,1,1,2,2,2,2,2,2,2,2,1,1,0,0],
    [0,0,0,1,1,2,2,2,2,2,2,1,1,0,0,0],
    [0,0,0,0,1,1,2,2,2,2,1,1,0,0,0,0],
    [0,0,0,0,0,1,1,2,2,1,1,0,0,0,0,0],
    [0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0],
    [empty]*16,
    [empty]*16
]

with open('generateBlock.dat',mode='w') as file:
    for i in range(16):
        for k in range(16):
            print(i,k)
            j = BITMAP[i][k]
            if j == empty:
                file.write(f'assign bitmap[{i}][{k}] = EMPTY;\n')
            elif j == red:
                file.write(f'assign bitmap[{i}][{k}] = RED;\n')
            elif j == white:
                file.write(f'assign bitmap[{i}][{k}] = WHITE;\n')
            elif j == black:
                file.write(f'assign bitmap[{i}][{k}] = BLACK;\n')

print("finish")