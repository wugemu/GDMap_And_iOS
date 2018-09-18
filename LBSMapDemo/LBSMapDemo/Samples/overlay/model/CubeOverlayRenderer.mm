//
//  StereoOverlayRenderer.m
//  MAMapKit_Debug
//
//  Created by yi chen on 1/12/16.
//  Copyright © 2016 Autonavi. All rights reserved.
//


#import "CubeOverlayRenderer.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

template <typename T>
struct Vector3 {
    Vector3() {}
    Vector3(T x, T y, T z) : x(x), y(y), z(z) {}
    T x;
    T y;
    T z;
};

typedef Vector3<float> Vertex;

@interface CubeOverlayRenderer()

@end

const GLuint totalVertexCount = 8;  //总顶点数
const GLuint indexCount       = 36; //索引数

@implementation CubeOverlayRenderer
{
    float _vertext[totalVertexCount * 3];
    short _indecies[indexCount];
    float _color[totalVertexCount * 4];
    
    float _scale[16];
    
    NSUInteger _cubePointCount;
    
    GLuint _program;
    GLuint _vertexLocation;
    GLuint _indicesLocation;
    GLuint _colorLocation;
    
    GLuint _viewMatrixLocation;
    GLuint _projectionMatrixLocation;
    GLuint _scaleMatrixLocation;
}

#pragma mark - Interface

- (CubeOverlay *)cubeOverlay
{
    return (CubeOverlay *)self.overlay;
}

- (void)initShader
{
    NSString *vertexShader = @"precision highp float;\n\
    attribute vec3 aVertex;\n\
    attribute vec4 aColor;\n\
    uniform mat4 aViewMatrix;\n\
    uniform mat4 aProjectionMatrix;\n\
    uniform mat4 aTransformMatrix;\n\
    uniform mat4 aScaleMatrix;\n\
    varying vec4 color;\n\
    void main(){\n\
    gl_Position = aProjectionMatrix * aViewMatrix * aScaleMatrix * vec4(aVertex, 1.0);\n\
    color = aColor;\n\
    }";
    
    NSString *fragmentShader = @"\n\
    precision highp float;\n\
    varying vec4 color;\n\
    void main(){\n\
    gl_FragColor = color;\n\
    }";
    
    
    _program = glCreateProgram();
    
    GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
    
    GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
    
    GLint vlength = (GLint)[vertexShader length];
    
    GLint flength = (GLint)[fragmentShader length];
    
    
    const GLchar *vByte = [vertexShader UTF8String];
    const GLchar *fByte = [fragmentShader UTF8String];
    
    glShaderSource(vShader, 1, &vByte, &vlength);
    
    glShaderSource(fShader, 1, &fByte, &flength);
    
    
    glCompileShader(vShader);
    
    glCompileShader(fShader);
    
    
    glAttachShader(_program, vShader);
    
    
    glAttachShader(_program, fShader);
    
    
    glLinkProgram(_program);
    
    
    
    _vertexLocation  = glGetAttribLocation(_program, "aVertex");
    
    
    _viewMatrixLocation = glGetUniformLocation(_program,"aViewMatrix");
    
    
    _projectionMatrixLocation = glGetUniformLocation(_program,"aProjectionMatrix");
    
    
    _scaleMatrixLocation = glGetUniformLocation(_program, "aScaleMatrix");
    
    _colorLocation = glGetAttribLocation(_program,"aColor");
    
}

/* 计算经纬度坐标对应的OpenGL坐标，每次地图坐标系有变化均会调用这个方法。 */
- (void)initVertext
{
    /* 创建vertex。 */
    float vertext[] = {
        0.0, 0.0, 0.0,
        2.0, 0.0, 0.0,
        2.0,  2.0, 0.0,
        0.0,  2.0, 0.0,
        0.0, 0.0,  2.0,
        2.0, 0.0,  2.0,
        2.0,  2.0,  2.0,
        0.0,  2.0,  2.0,
    };
    
    for (int i = 0; i < 24; i++) {
        _vertext[i] = vertext[i];
    }
    
    
    short indices[] = {
        0, 4, 5,
        0, 5, 1,
        1, 5, 6,
        1, 6, 2,
        2, 6, 7,
        2, 7, 3,
        3, 7, 4,
        3, 4, 0,
        4, 7, 6,
        4, 6, 5,
        3, 0, 1,
        3, 1, 2,
    };
    
    for (int i = 0; i < 36; i++) {
        _indecies[i] = indices[i];
    }
    
    float colors[] = {
        1.0f, 0.0f, 0.0f, 1.0f, // vertex 0 red
        0.0f, 1.0f, 0.0f, 1.0f, // vertex 1 green
        0.0f, 0.0f, 1.0f, 1.0f, // vertex 2 blue
        1.0f, 1.0f, 0.0f, 1.0f, // vertex 3
        0.0f, 1.0f, 1.0f, 1.0f, // vertex 4
        1.0f, 0.0f, 1.0f, 1.0f, // vertex 5
        0.0f, 0.0f, 0.0f, 1.0f, // vertex 6
        1.0f, 1.0f, 1.0f, 1.0f, // vertex 7
    };
    
    for (int i = 0; i < 32; i++) {
        _color[i] = colors[i];
    }
    
    float scale[] = {
        1.0f, 0.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    };
    
    for (int i = 0; i < 16; i++) {
        _scale[i] = scale[i];
    }
    
    
    
}
void translateM(float* m, int mOffset,float x, float y, float z) {
    for (int i=0 ; i<4 ; i++) {
        int mi = mOffset + i;
        m[12 + mi] += m[mi] * x + m[4 + mi] * y + m[8 + mi] * z;
    }
}

/* OpenGL绘制。 */
- (void)glRender
{
    if (_program == 0) {
        [self initShader];
        [self initVertext];
        
        ///设定缩放矩阵，在当前级别的10屏幕像素大小
        _scale[0] = 10 * [self glWidthForWindowWidth:1];
        _scale[5] = 10 * [self glWidthForWindowWidth:1];
        _scale[10] = 10 * [self glWidthForWindowWidth:1];
    }
    
    glUseProgram(_program);
    
    glEnable(GL_DEPTH_TEST);
    
    glEnableVertexAttribArray(_vertexLocation);
    
    glVertexAttribPointer(_vertexLocation, 3, GL_FLOAT, false, 0, _vertext);
    
    glEnableVertexAttribArray(_colorLocation);
    
    glVertexAttribPointer(_colorLocation, 4, GL_FLOAT, false, 0, _color);
    
    MAMapPoint center = MAMapPointForCoordinate(self.overlay.coordinate);
    CGPoint offsetPoint = [self glPointForMapPoint:center];
    
    glUniformMatrix4fv(_scaleMatrixLocation, 1, false, _scale);
    
    
    float * viewMatrix = [self getViewMatrix];
    
    translateM(viewMatrix, 0, offsetPoint.x, offsetPoint.y, 0);
    
    float * projectionMatrix = [self getProjectionMatrix];
    
    glUniformMatrix4fv(_viewMatrixLocation, 1, false, viewMatrix);
    
    glUniformMatrix4fv(_projectionMatrixLocation, 1, false, projectionMatrix);
    
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, _indecies);
    
    glDisableVertexAttribArray(_vertexLocation);
    
    glDisableVertexAttribArray(_colorLocation);
    
    glDisable(GL_DEPTH_TEST);
    
    
    
}

#pragma mark - Helper

- (CGFloat)lengthBetweenPointA:(CGPoint)a andPointB:(CGPoint)b
{
    CGFloat deltaX = a.x - b.x;
    CGFloat deltaY = a.y - b.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
}


#pragma mark - Init

- (instancetype)initWithCubeOverlay:(CubeOverlay *)cubeOverlay
{
    self = [super initWithOverlay:cubeOverlay];
    if (self)
    {
        //        [self initShader];
        //        [self initVertext];
    }
    
    return self;
}

- (instancetype)initWithOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[CubeOverlay class]])
    {
        return nil;
    }
    
    return [self initWithCubeOverlay:overlay];
}

@end
