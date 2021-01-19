//
//  POCDefaultShader.m
//  rcv
//
//  Created by rcadmin on 2020/12/24.
//  Copyright © 2020 RingCentral. All rights reserved.
//

#import "POCDefaultShader.h"

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

#import "RTCOpenGLDefines.h"
#import "RTCShader.h"
#import <WebRTC/WebRTC.h>

#include "absl/types/optional.h"

static const int kTextureUnit = 0;

// Fragment shader converts YUV values from input textures into a final RGB
// pixel. The conversion formula is from http://www.fourcc.org/fccyvrgb.php.
static const char kNV12FragmentShaderSource[] =
  SHADER_VERSION
  "precision mediump float;"
  FRAGMENT_SHADER_IN " vec2 v_texcoord;\n"
  "uniform lowp sampler2D s_textureY;\n"
  FRAGMENT_SHADER_OUT
  "void main() {\n"
  "    " FRAGMENT_SHADER_COLOR " = " FRAGMENT_SHADER_TEXTURE "(s_textureY, v_texcoord);\n"
  "  }\n";

@implementation POCDefaultShader {
  GLuint _vertexBuffer;
  GLuint _vertexArray;
  // Store current rotation and only upload new vertex data when rotation changes.
  absl::optional<RTCVideoRotation> _currentRotation;
  GLuint _nv12Program;
}

- (void)dealloc {
  glDeleteProgram(_nv12Program);
  glDeleteBuffers(1, &_vertexBuffer);
  glDeleteVertexArrays(1, &_vertexArray);
}

- (BOOL)createAndSetupNV12Program {
  NSAssert(!_nv12Program, @"NV12 program already created");
  _nv12Program = RTCCreateProgramFromFragmentSource(kNV12FragmentShaderSource);
  if (!_nv12Program) {
    return NO;
  }
  GLint ySampler = glGetUniformLocation(_nv12Program, "s_textureY");

  if (ySampler < 0) {
    RTCLog(@"Failed to get uniform variable locations in NV12 shader");
    glDeleteProgram(_nv12Program);
    _nv12Program = 0;
    return NO;
  }

  glUseProgram(_nv12Program);
  glUniform1i(ySampler, kTextureUnit);

  return YES;
}

- (BOOL)prepareVertexBufferWithRotation:(RTCVideoRotation)rotation {
  if (!_vertexBuffer && !RTCCreateVertexBuffer(&_vertexBuffer, &_vertexArray)) {
    RTCLog(@"Failed to setup vertex buffer");
    return NO;
  }
#if !TARGET_OS_IPHONE
  glBindVertexArray(_vertexArray);
#endif
  glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
  if (!_currentRotation || rotation != *_currentRotation) {
    _currentRotation = absl::optional<RTCVideoRotation>(rotation);
    RTCSetVertexData(*_currentRotation);
  }
  return YES;
}

- (void)applyShadingForFrameWithWidth:(int)width
                               height:(int)height
                             rotation:(RTCVideoRotation)rotation
                              texture:(GLuint)texture {
  if (![self prepareVertexBufferWithRotation:rotation]) {
    return;
  }

  if (!_nv12Program && ![self createAndSetupNV12Program]) {
    RTCLog(@"Failed to setup NV12 shader");
    return;
  }

  glUseProgram(_nv12Program);

  glActiveTexture(static_cast<GLenum>(GL_TEXTURE0 + kTextureUnit));
  glBindTexture(GL_TEXTURE_2D, texture);

  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
  glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

@end
