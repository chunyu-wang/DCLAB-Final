# Fruit Ninja AR
## Abstract
AR Fruit Ninja that fully rely on image processing.


## Checklist

### Baseline
- [ ] Capture Camera Data
    - [ ] HSMC spec
    - [ ] Find a way to debug 
- [ ] VGA Display
    - [ ] VGA spec
    - [ ] Display plain color
    - [ ] Display color blocks
    - [ ] Display moving blocks
- [ ] Object Detection on Computer w/ OpenCV
    - [ ] Turn video into images
    - [ ] Detect the location of the rod
    - [ ] Detect the angle/motion of the rod (is player striking?)
- [ ] Implement the ROD
    - [ ] Decide where to place the marker
- [ ] System Architecture
    - [ ] How many module? 
- [ ] Write the report

### Medium
- [ ] Game image shown
    - [ ] ( subtask ) Camera Data overlaps with game image

- [ ] Object Detection on FPGA
    - [ ] Function normally 
    - [ ] Realtime
### Advanced
- [ ] Playable Game 
    - [ ] Generate random number ( for generate random circle to cut )
    - [ ] Record mysterious circle's position and cut it with the player's motion track
    - [ ] Timer of the game till end / Life count if cut a bomb or whatever
    - [ ] Record Score 
### Optional 
- [ ] Add sound effect
- [ ] Some stickers for mysterious object
- [ ] Animation of the cut object
- [ ] MultiPlayer
### Fallback Plan
- [ ] Object Detection/ Render on Computer and send data through usb
### Further fallback plan
- [ ] Do image process on computer and send result to FPGA
## Content (what this project is doing)
### **[Base]**
Specific object position detection / Object orientation detection with an image

### **[Advance]**
Specific Object position detection / Object orientation detection in real time

### **[Expert]**
A game of **Fruit Ninja**

Player uses a rod like object with **tracing color ring** on it to play.

No playground,only with black background. The player should slash the mysterious object (2D object or even a simple circle is fine) in screen.

### **[Hell]**
A game of **Fruit Ninja with AR**

Player uses a rod like object with **tracing color ring** on it to play.

Playground is the real world, and the player should slash the mysterious object (2D object or even a simple circle is fine) in screen.

### **[Abandoned All Hope]**
Multiplayer game

## Requirement
- ~~gyro sensor(?)~~
- camera
- [CLR-HSMC Camera Link Receiver Daughter Card](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=68&No=588&PartNo=2#heading)

if it is not found in lab, we would probably start backup plan because it is too expensive
- rod
- background(?)

## Specs
- framerate?
- resolution?

## Object Tracking
[Simple Object Tracking with OpenCV](https://pyimagesearch.com/2018/07/23/simple-object-tracking-with-opencv/)

##### center of mass tracing method
---


[Mean shift and CamShift](https://docs.opencv.org/4.x/d7/d00/tutorial_meanshift.html)

##### object tracing for a constant shape object
---
[Past FPGA Project](https://github.com/brunaanog/Object-Tracking-and-Detection-on-FPGA-Board-Cyclone-II)
##### object trace for object that is not in  the background image
---


## Camera
### 資料處理
- How to debug?
### 記憶體問題

## VGA


## 遊戲本體

