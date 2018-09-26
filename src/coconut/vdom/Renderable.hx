package coconut.vdom;

#if !macro
import js.html.Element;
import tink.CoreApi;
import tink.state.Observable;
import vdom.Attr.Key;
import vdom.VDom.*;
import vdom.*;

class Renderable extends Widget {
  
  @:noCompletion var __rendered:Observable<coconut.ui.RenderResult>;
  @:noCompletion var __dom:Element;
  @:noCompletion var __binding:CallbackLink;
  @:noCompletion var __lastRender:VNode;
  
  static var keygen = 0;
  @:noCompletion @:keep @:native('key') var virtualDomKey:Key = keygen++;
  
  public function new(rendered) {
    this.__rendered = rendered;
  }
        
  @:noCompletion override public function init():Element {
    if (__binding == null) {
      if (__dom != null) {
        this.beforeInit();
        var next = __rendered.value;
        var changes = diff(__lastRender, next);
        __lastRender = next;
        this.__dom = patch(__dom, changes);    
      }
      else {
        __lastRender = __rendered.value;
        this.beforeInit();
        this.__dom = create(__lastRender);
      }
      this.afterInit(__dom);
      __setupBinding();
    }
    
    return this.__dom;
  }
  
  @:noCompletion function __setupBinding()
    this.__binding = this.__rendered.bind(function (next) {
      if (next != __lastRender) __apply(next);
    });
  
  @:noCompletion function __apply(next) {
    var changes = diff(__lastRender, next);
    beforePatching(this.__dom);
    this.__dom = patch(__dom, changes);
    __lastRender = next;
    afterPatching(this.__dom);
  }
  
  public inline function toElement() 
    return init();

  @:noCompletion function beforeInit() {}
  @:noCompletion function afterInit(element:Element) {}
  @:noCompletion function beforePatching(element:Element) {}
  @:noCompletion function afterPatching(element:Element) {}
  @:noCompletion function beforeDestroy(element:Element) {}
  @:noCompletion function afterDestroy(element:Element) {}
  
  @:noCompletion override public function update(x:{}, y):Element {
    switch Std.instance(x, Renderable) {
      case null:
      case v: __reuseRender(v);
    }
    return toElement();
  }

  @:noCompletion private function __reuseRender(that:Renderable) {
    this.__dom = that.__dom;
    this.__lastRender = that.__lastRender;
    __apply(__rendered);
    __setupBinding();
    that.destroy();
  }
  
  macro function get(_, e);
  macro function hxx(e);

  @:noCompletion override public function destroy():Void {
    beforeDestroy(this.__dom);
    this.__binding.dissolve();
    this.__binding = null;
    super.destroy();
    
    function _destroy(v:VNode) {
      switch ((cast v).children:Array<Dynamic>) {
        case null:
        case children:
          for(child in children) {
            switch Std.instance(child, Widget) {
              case null:
              case v: v.destroy();
            }
            _destroy(child);
          }
      }
    }
    _destroy(__lastRender);
    afterDestroy(this.__dom);
  }  
}
#else
class Renderable {
 
  macro function get(_, e) 
    return coconut.vdom.macros.Select.typed(e);
  macro function hxx(_, e) 
    return 
      #if coconut_ui
        coconut.ui.macros.HXX.parse(e);
      #else
        vdom.VDom.hxx(e);
      #end
}
#end
