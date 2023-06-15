import cv2
import numpy as np

# PIC = "pic0"
# ROUTE = "./tb/pic/" + PIC + '/'
# SOURCE = ROUTE + PIC + '.jpg'

# pic = cv2.imread(SOURCE)

h = [40,75]
s = [60,230]
v = [80,255]

len1 = h[1] - h[0] + 1
len2 = s[1] - s[0] + 1

img = np.zeros([len2,len1,3])

for i in range(h[0],h[1]+1,1):
    for j in range(s[0],s[1]+1,1):
        img[j-s[0]][i-h[0]][0] = i
        img[j-s[0]][i-h[0]][1] = j
        img[j-s[0]][i-h[0]][2] = 255

# img = cv2.cvtColor(img,cv2.COLOR_HSV2BGR)

cv2.imwrite('python/color_img.jpg', img)


img = cv2.imread('python/color_img.jpg')

img = cv2.cvtColor(img,cv2.COLOR_HSV2BGR)
cv2.imwrite('python/rgb_img.jpg', img)

cv2.imshow("image", img)
cv2.waitKey()