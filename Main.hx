package ;


import flash.geom.Vector3D;
import flash.Lib;
import flash.display.Stage3D;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.shaders.AGLSLShaderUtils;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.Vector.Vector;
using OpenFLStage3D;
import flash.display3D.shaders.Shader;

#if (cpp || neko || js)
import openfl.gl.GL; 
#end
/**
 * ...
 * @author 
 */
class Main extends Sprite
{
	
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
	public static function main() 
	{
		

		//haxe.Log.trace = myTrace;
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
 
	private var context3D:Context3D;
	private var vertexbuffer:VertexBuffer3D;
	private var indexBuffer:IndexBuffer3D; 
	private var program:Program3D; 
	private var stage3D : Stage3D;
	public function new() 
	{
		super();
		
		
		
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT; 
		
		stage3D = stage.getStage3D(0);
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, init); 
        stage3D.requestAGLSLContext3D(); 
			 
	}
	
	private function init(e:Event):Void
	{
		
		context3D =stage3D.context3D;	
		
		context3D.configureBackBuffer(800, 480, 1, false); 
		var vertexData:Array<Float> = [-0.3,-0.3,0, 1, 0, 0, // x, y, z, r, g, b
				-0.3, 0.3, 0, 0, 1, 0,
				0.3, 0.3, 0, 0, 0, 1];
		var indexData:Array<UInt> = [0, 1, 2];
		program = context3D.createProgram(); 
		// 3 vertices, of 6 Numbers each
		vertexbuffer = context3D.createVertexBuffer(3, 6); 
		vertexbuffer.uploadFromVector(flash.Vector.ofArray(vertexData), 0, 3);
		 
		indexBuffer = context3D.createIndexBuffer(3);			
	 
		
		// offset 0, count 3
		indexBuffer.uploadFromVector(flash.Vector.ofArray(indexData), 0, 3);
			 
		var vertexShaderAssembler : Shader = AGLSLShaderUtils.createShader( Context3DProgramType.VERTEX,
			"m44 op, va0, vc0\n" +
			"mov v0, va1\n"
		);
		var fragmentShaderAssembler : Shader= AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT,
			"mov oc, v0\n"
		);
		 
		
		program.upload( vertexShaderAssembler, fragmentShaderAssembler);
	
		context3D.setRenderCallback(onRender);
		
		rot = 0;
	}
	
	private var rot:Float;
	private function onRender(e:Event):Void
	{
		//return;
		if (context3D==null) 
			return;
				
		rot += .5;
		if (rot >= 360) rot = 1;
 
	
	
		 
        context3D.setProgram(program);
       
		 

		// vertex position to attribute register 0
		context3D.setVertexBufferAt (0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		// uv coordinates to attribute register 1
		context3D.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_3);	
		// assign shader program
	 
		
		var matrix3D:Matrix3D = new Matrix3D();    
	 
		matrix3D.identity(); 
		//matrix3D.appendRotation(30, Vector3D.Z_AXIS);
		matrix3D.appendRotation(rot, Vector3D.Z_AXIS);    
		
		context3D.clear (1, 0, 0, 1);
	 
		context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix3D, false);
		context3D.drawTriangles(indexBuffer, 0, 1); 
	 
		 
		context3D.present();
	}
	 
}

