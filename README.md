# WebRTCVirtualBackgroundPOC

本POC主要是为了实验背景虚化效果与WebRTC结合,即通过```RTCCameraVideoCapturer```采集视频,采集完后在```- (void)capturer: (RTCVideoCapturer *)capturer didCaptureVideoFrame: (RTCVideoFrame *)frame```回调中对每个buffer进行处理,扣出人像并且设置背景透明.当处理完每一个buffer后传递给WebRTC的是BGRA的格式,
而WebRTC不支持alpha通道(出于流量考虑?),所以在源码中WebRTC的内置着色器(详见源码```RTCDefaultShader```中的```kNV12FragmentShaderSource```)会把BGRA转成RGB在用于显示,这样导致alphe通道被丢弃,在屏幕上渲染出来的效果是除了人像背景是黑色的,预期背景是白色透明. 
#### 解决方案:
由于着色器是硬编码在```RTCDefaultShader```中,因为外部没法通过修改着色器的方式支持alpha通道,故采取复写整个```RTCDefaultShader```类 -> ```POCDefaultShader```,再用```POCDefaultShader```替换原来```RTCDefaultShader```.
这样相应的类```RTCNV12TextureCache,RTCEAGLVideoView```等都要有一份复写,详见工程中的FixWebRTC目录.这样启用背景虚化特效时采用FixWebRTC下的类处理并显示每一帧.这个方案显然比较麻烦,但是也是一种方案供参考学习.
