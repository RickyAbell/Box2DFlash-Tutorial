package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import Box2D.Common.Math.*;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.*;
 
	/**
	 * Basic tutorial on Box2DFlash for Dev.Mag www.devmag.org.za
	 * @author Dev.Mag & Ricky Abell
	 */
	public class Main extends Sprite
	{
		private var world:b2World;
		private var timestep:Number;
		private var velocityIterations:uint;
		private var positionIterations:uint;
		private var pixelsPerMeter:Number = 30;
		private var genBodyTimer:Timer;		
		private var sideWallWidth:int = 20;
		private var bottomWallHeight:int = 25;
		private var bodyCount:int = 0;
 
		public function Main():void
		{ 
			this.initWorld();
			this.createWalls();
			this.createStaticBodies();
			this.setupDebugDraw();			
			
			this.genBodyTimer = new Timer(500);
			this.genBodyTimer.addEventListener(TimerEvent.TIMER, this.genRandomBody);
 
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init); 
		}
 
		private function initWorld():void
		{
			var gravity:b2Vec2 = new b2Vec2(0.0, 9.8);			
			var doSleep:Boolean = true;
			
			// Construct world
			this.world = new b2World(gravity, doSleep);
			this.world.SetWarmStarting(true);
			this.timestep = 1.0 / 30.0;
			this.velocityIterations = 6;
			this.positionIterations = 4;
		}
 
		private function createWalls():void
		{
			var wallShape:b2PolygonShape = new b2PolygonShape();
			var wallBd:b2BodyDef = new b2BodyDef();
			var wallB:b2Body;
			
			wallShape.SetAsBox(sideWallWidth / pixelsPerMeter / 2, this.stage.stageHeight / pixelsPerMeter / 2);
 
			//Left wall
			wallBd.position.Set((sideWallWidth / 2) / pixelsPerMeter, this.stage.stageHeight / 2 / pixelsPerMeter);
			wallB = world.CreateBody(wallBd);
			wallB.CreateFixture2(wallShape);
			
			//Right wall
			wallBd.position.Set((this.stage.stageWidth - (sideWallWidth / 2)) / pixelsPerMeter, this.stage.stageHeight / 2 / pixelsPerMeter);
			wallB = world.CreateBody(wallBd);
			wallB.CreateFixture2(wallShape);
			
			//Bottom wall
			wallShape.SetAsBox(this.stage.stageWidth / pixelsPerMeter / 2, bottomWallHeight / pixelsPerMeter / 2);
			wallBd.position.Set(this.stage.stageWidth / 2 / pixelsPerMeter, (this.stage.stageHeight - (bottomWallHeight / 2)) / pixelsPerMeter);
			wallB = world.CreateBody(wallBd);
			wallB.CreateFixture2(wallShape);
 
		}
		
		private function createStaticBodies():void 
		{
			var blockBody:b2Body;
			var blockBd:b2BodyDef = new b2BodyDef();
			var blockShape:b2PolygonShape = new b2PolygonShape();
			var rectHeight:int = 30;
		
			//Create a stack of static rectangular bodies for our randomly generated bodies to interact with.
			blockBd.position.Set(this.stage.stageWidth / 2 / pixelsPerMeter, (this.stage.stageHeight - this.bottomWallHeight - (rectHeight / 2)) / pixelsPerMeter);			
			blockShape.SetAsBox(320 / pixelsPerMeter / 2, rectHeight / pixelsPerMeter / 2);			
			blockBody = world.CreateBody(blockBd);
			blockBody.CreateFixture2(blockShape);
			
			blockBd.position.Set(this.stage.stageWidth / 2 / pixelsPerMeter, (this.stage.stageHeight - (this.bottomWallHeight + rectHeight) - (rectHeight / 2)) / pixelsPerMeter);			
			blockShape.SetAsBox(240 / pixelsPerMeter / 2, rectHeight / pixelsPerMeter / 2);
			blockBody = world.CreateBody(blockBd);
			blockBody.CreateFixture2(blockShape);
			
			blockBd.position.Set(this.stage.stageWidth / 2 / pixelsPerMeter, (this.stage.stageHeight - (this.bottomWallHeight + 2 * rectHeight) - (rectHeight / 2)) / pixelsPerMeter);			
			blockShape.SetAsBox(140 / pixelsPerMeter / 2, rectHeight / pixelsPerMeter / 2);			
			blockBody = world.CreateBody(blockBd);
			blockBody.CreateFixture2(blockShape);
		}
 
		private function setupDebugDraw():void
		{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			addChild(debugSprite);
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetDrawScale(30.0);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(debugDraw);
		}
 
		private function init(e:Event = null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.ENTER_FRAME, update);
			this.genBodyTimer.start();
		}
		
		private function genRandomBody(e:TimerEvent):void
		{
			if (this.bodyCount < 40)
			{
				var bodyType:Number = Math.random();
				(bodyType < 0.5) ? this.genCircle() : this.genRectangle();
				this.bodyCount++;
			}
		}
		
		private function genCircle():void
		{
			var body:b2Body;
			var fd:b2FixtureDef;
			
			var bodyDefC:b2BodyDef = new b2BodyDef();
			bodyDefC.type = b2Body.b2_dynamicBody;
			
			var circShape:b2CircleShape = new b2CircleShape((Math.random() * 7 + 10) / pixelsPerMeter);
			fd = new b2FixtureDef();
			fd.shape = circShape;
			fd.density = 1.0;
			fd.friction = 0.3;
			fd.restitution = 0.1;
			bodyDefC.position.Set((Math.random() * (this.stage.stageWidth - sideWallWidth - 20) + sideWallWidth + 20) / pixelsPerMeter, (Math.random() * 80 + 40) / pixelsPerMeter);
			bodyDefC.angle = Math.random() * Math.PI;
			body = world.CreateBody(bodyDefC);
			body.CreateFixture(fd);
		}
		
		private function genRectangle():void
		{
			var body:b2Body;
			var fd:b2FixtureDef = new b2FixtureDef();
			var rectDef:b2BodyDef = new b2BodyDef();
			rectDef.type = b2Body.b2_dynamicBody;
			var polyShape:b2PolygonShape = new b2PolygonShape();			
			
			fd.shape = polyShape;
			fd.density = 1.0;
			fd.friction = 0.3;
			fd.restitution = 0.1;
			polyShape.SetAsBox((Math.random() * 16 + 20) / pixelsPerMeter / 2, (Math.random() * 16 + 20) / pixelsPerMeter / 2);
			rectDef.position.Set((Math.random() * (this.stage.stageWidth - 2 * (sideWallWidth + 20)) + (sideWallWidth + 20)) / pixelsPerMeter, (Math.random() * 80 + 40) / pixelsPerMeter);
			rectDef.angle = Math.random() * Math.PI;
			body = world.CreateBody(rectDef);
			body.CreateFixture(fd);
		}
		
		private function update(e:Event = null):void
		{			
			world.Step(timestep, velocityIterations, positionIterations);
			world.ClearForces();
			world.DrawDebugData();
		}
 
	}
	
}