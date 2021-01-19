//
//  POCNV12TextureCache.m
//  rcv
//
//  Created by rcadmin on 2020/12/25.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import "POCNV12TextureCache.h"
#import <WebRTC/WebRTC.h>
#import <OpenGLES/ES3/glext.h>


//#import <OpenGLES/ES3/gl.h>

@implementation POCNV12TextureCache {
  CVOpenGLESTextureCacheRef _textureCache;
  CVOpenGLESTextureRef _textureRef;
}

- (GLuint)texture {
  return CVOpenGLESTextureGetName(_textureRef);
}

- (instancetype)initWithContext:(EAGLContext *)context {
  if (self = [super init]) {
    CVReturn ret = CVOpenGLESTextureCacheCreate(
        kCFAllocatorDefault, NULL,
#if COREVIDEO_USE_EAGLCONTEXT_CLASS_IN_API
        context,
#else
        (__bridge void *)context,
#endif
        NULL, &_textureCache);
    if (ret != kCVReturnSuccess) {
      self = nil;
    }
  }
  return self;
}

- (BOOL)loadTexture:(CVOpenGLESTextureRef *)textureOut
        pixelBuffer:(CVPixelBufferRef)pixelBuffer
        pixelFormat:(GLenum)pixelFormat {
  const int width = CVPixelBufferGetWidth(pixelBuffer);
  const int height = CVPixelBufferGetHeight(pixelBuffer);
    
  if (*textureOut) {
    CFRelease(*textureOut);
    *textureOut = nil;
  }

  CVReturn ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, width, height, GL_BGRA, GL_UNSIGNED_BYTE, 0, textureOut);
//    CVReturn ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, GL_RENDERBUFFER, GL_RGBA8, width, height, GL_RGBA, GL_UNSIGNED_BYTE, 0, textureOut);
    
  if (ret != kCVReturnSuccess) {
    if (*textureOut) {
      CFRelease(*textureOut);
      *textureOut = nil;
    }
    return NO;
  }
  NSAssert(CVOpenGLESTextureGetTarget(*textureOut) == GL_TEXTURE_2D,
           @"Unexpected GLES texture target");
  glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(*textureOut));
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  return YES;
}

- (BOOL)uploadFrameToTextures:(RTC_OBJC_TYPE(RTCVideoFrame) *)frame {
  NSAssert([frame.buffer isKindOfClass:[RTC_OBJC_TYPE(RTCCVPixelBuffer) class]],
           @"frame must be CVPixelBuffer backed");
  RTC_OBJC_TYPE(RTCCVPixelBuffer) *rtcPixelBuffer = (RTC_OBJC_TYPE(RTCCVPixelBuffer) *)frame.buffer;
  CVPixelBufferRef pixelBuffer = rtcPixelBuffer.pixelBuffer;
  return [self loadTexture:&_textureRef
               pixelBuffer:pixelBuffer
               pixelFormat:GL_RGBA];
}

- (void)releaseTextures {
  if (_textureRef) {
    CFRelease(_textureRef);
    _textureRef = nil;
  }
}

- (void)dealloc {
  [self releaseTextures];
  if (_textureCache) {
    CFRelease(_textureCache);
    _textureCache = nil;
  }
}

@end
