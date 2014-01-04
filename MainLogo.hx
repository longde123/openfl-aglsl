package;


import flash.display.Sprite;
import flash.display.Stage;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.shaders.AGLSLShaderUtils;
import flash.display3D.shaders.Shader;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;

import flash.display3D.Context3D;
import flash.display.Stage3D; 
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.Context3DVertexBufferFormat;

import flash.display3D.textures.Texture;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DMipFilter;
import flash.display3D.Context3DTextureFilter;
import flash.display3D.Context3DWrapMode;

 

using OpenFLStage3D;

import flash.events.Event;
import flash.events.ErrorEvent;
 
   
class MainLogo extends Sprite {

    public static function myTrace(message : Dynamic, ?posInfos : haxe.PosInfos) : Void
    {
        #if flash
            flash.Lib.trace(message);
        #elseif js
             untyped console.log(message);
        #else
            untyped __trace(message, posInfos);
        #end

    }

    private var stage3D : Stage3D;
    private var context3D : Context3D;
    private var sceneProgram : Program3D;   

    private var vertexBuffer : VertexBuffer3D;
    private var indexBuffer : IndexBuffer3D;

    private var texture : Texture;

	public function new () {
        super ();

        haxe.Log.trace = myTrace;

        stage3D = stage.getStage3D(0);
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, onReady);
        stage3D.addEventListener(ErrorEvent.ERROR, onError);
        stage3D.requestAGLSLContext3D();
		
		
		//stage3D.x = 30;
		//stage3D.y = 30;


    }

	private function onError(event : ErrorEvent):Void{
	    trace(event);
    }

    private function onReady(event : Event) : Void{
        context3D = stage3D.context3D;
        context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
        context3D.enableErrorChecking = true;
		var vertexAgalInfo :String = "m44 vt0, va0, vc0\n" +
									"m44 op, vt0, vc4\n" +
									"mov v0, va1\n";
 

        var fragmentAgalInfo :String = "mov ft0, v0\n" +
										"tex ft1, ft0, fs0 <2d,wrap,linear>\n" +
										"mov oc, ft1\n";

        var vertexShader  : Shader = AGLSLShaderUtils.createShader( Context3DProgramType.VERTEX,vertexAgalInfo);  
        var fragmentShader  : Shader = AGLSLShaderUtils.createShader( Context3DProgramType.FRAGMENT,fragmentAgalInfo);

        sceneProgram = context3D.createProgram();
        sceneProgram.upload(vertexShader, fragmentShader);

        var logo = openfl.Assets.getBitmapData("assets/hxlogo.png");
        texture = context3D.createTexture(logo.width,logo.height, Context3DTextureFormat.BGRA,false);
        texture.uploadFromBitmapData(logo);

        var vertices : Array<Float> = [
            -100,   -100,   0,     0,   0,
            100,  -100,   0,     1,   0,
            -100,   100,  0,     0,   1,
            100,  100,  0,     1,   1
        ];

        vertexBuffer = context3D.createVertexBuffer(4,5);
        vertexBuffer.uploadFromVector(flash.Vector.ofArray(vertices), 0, 4);

        indexBuffer = context3D.createIndexBuffer(6);
        var indexes : Array<UInt> = [0,1,2,1,2,3];
        indexBuffer.uploadFromVector(flash.Vector.ofArray(indexes), 0, 6);

        context3D.setBlendFactors(flash.display3D.Context3DBlendFactor.SOURCE_ALPHA, flash.display3D.Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        context3D.setRenderCallback(renderView);
		
		//context3D.setScissorRectangle(new Rectangle(30,30,100,100));
    }

	private function renderView (event : Event):Void {
       

		
		var positionX = stage.stageWidth / 2;
		var positionY = stage.stageHeight / 2;
		var projectionMatrix = Matrix3DUtils.createOrtho (0, stage.stageWidth, stage.stageHeight, 0, 1000, -1000);
		var modelViewMatrix = Matrix3DUtils.create2D (positionX, positionY, 1, 0);

        //var matrix = modelViewMatrix;
        //matrix.append(projectionMatrix);
		context3D.setProgram(sceneProgram); 
        context3D.setVertexBufferAt(0,vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);
        context3D.setVertexBufferAt(1,vertexBuffer,3,Context3DVertexBufferFormat.FLOAT_2);
        context3D.setTextureAt(0,texture);
        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,projectionMatrix,false);
        context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,4,modelViewMatrix,false);
        //sceneProgram.setVertexUniformFromMatrix("matrix",matrix, true);
        //sceneProgram.setSamplerStateAt("texture",Context3DWrapMode.CLAMP,Context3DTextureFilter.LINEAR,Context3DMipFilter.MIPNONE);
		context3D.clear(0, 0.5, 0, 0);
        context3D.drawTriangles(indexBuffer);
        context3D.present();
	}

}
