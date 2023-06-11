import cv2
import numpy as np
PIC = "pic0"
ROUTE = "./tb/pic/" + PIC + '/'
SOURCE = ROUTE + PIC + '.jpg'
WIDTH = 640
HEIGHT = 480

pic = cv2.imread(SOURCE)

pic = cv2.resize(pic,(WIDTH,HEIGHT),interpolation=cv2.INTER_AREA)

with open(ROUTE+'testbench.dat','w') as testbench:
    for i in range(HEIGHT):
        for j in range(WIDTH):
            b,g,r = pic[i][j]
            b,g,r = bin(b)[2:],bin(g)[2:],bin(r)[2:]
            max_len = 8
            b = "0"*(max_len-len(b)) + b
            g = "0"*(max_len-len(g)) + g
            r = "0"*(max_len-len(r)) + r
            # print(i,j,b,g,r)
            testbench.write(r+'\n')
            testbench.write(g+'\n')
            testbench.write(b+'\n')

pic = cv2.imread(SOURCE)

pic = cv2.resize(pic,(WIDTH,HEIGHT),interpolation=cv2.INTER_AREA)
pic = cv2.cvtColor(pic,cv2.COLOR_BGR2HSV)

low = [30,60,80]
high = [75,230,255]
mask = cv2.inRange(pic, np.array(low), np.array(high))
IMG = cv2.bitwise_and(pic, pic, mask=mask)


with open(ROUTE+'golden.dat','w') as golden:
    for i in range(HEIGHT):
        for j in range(WIDTH):
            b,g,r = pic[i][j]
            b,g,r = b*2, g, r
            # print(pic[i][j])
            # break
            b,g,r = bin(b)[2:],bin(g)[2:],bin(r)[2:]
            max_len = 10
            b = "0"*(max_len-len(b)) + b
            g = "0"*(max_len-len(g)) + g
            r = "0"*(max_len-len(r)) + r
            # print(i,j,b,g,r)
            golden.write(b+'\n')
            golden.write(g+'\n')
            golden.write(r+'\n')
while(True):
    cv2.imshow('123',IMG)
    if cv2.waitKey(1) == ord('q'):
        cv2.destroyAllWindows()