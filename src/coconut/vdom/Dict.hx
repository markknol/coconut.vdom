package coconut.vdom;

abstract Dict<T>(Dynamic<T>) from Dynamic<T> to Dynamic<T> {
	
	public inline function new() this = {};

	@:arrayAccess inline function get(key:String):T
		return untyped this[key];

  public inline function keys():Array<String>
    return getKeys(cast this);

	static inline public function getKeys(target:Dynamic):Array<String>
		return untyped Object.getOwnPropertyNames(target);
}  