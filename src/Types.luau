--!strict

--[=[
    @type ShapeType "Block" | "Ball" | "Cylinder" | "Wedge" | "CornerWedge"
    @within QuickZone
    The geometric shape of a Zone.
]=]
export type ShapeType = 'Block' | 'Ball' | 'Cylinder' | 'Wedge' | 'CornerWedge'

--[=[
    @type ZoneReference BasePart | Attachment | Bone
    @within QuickZone
    The physical instances that a Zone can track and sync to.
]=]
export type ZoneReference = BasePart | Attachment | Bone

--[=[
    @interface EntityTable
    @within QuickZone
    A custom table that mimics the spatial properties of a Roblox Instance. 
]=]
export type EntityTable = {
	Position: Vector3?,
	WorldPosition: Vector3?,
	CFrame: CFrame?,
	Transform: CFrame?,
	GetPivot: ((self: any) -> CFrame)?,
}

--[=[
    @type Entity BasePart | Model | Camera | Attachment | Bone | EntityTable
    @within QuickZone
]=]
export type Entity = BasePart | Model | Camera | Attachment | Bone | EntityTable

export type BoundingVolume = {
	position: Vector3,
	cframe: CFrame,
	halfSize: Vector3,
	type: ShapeType,
	radiusSq: number?,
	start: Vector3?,
	axis: Vector3?,
	axisLength: number?,
}

export type Node = {
	min: Vector3,
	max: Vector3,
	id: number,
	skipIndex: number,
}

export type Tree = {
	nodes: { Node },
	count: number,
}

export type EntityData = {
	activeObserverMemberships: { [number]: number },
	lastPosition: Vector3,
	strategy: number,
	precisionSq: number,
	updateRate: number,
	bucketIndex: number,
	staticVersion: number,
	dynamicVersion: number,
	logicVersion: number,
	needsStatic: boolean,
	needsDynamic: boolean,
}

-- Group

export type Group<T = any> = {
	add: (self: any, entity: T) -> Group<T>,
	addBulk: (self: any, entities: { T }) -> Group<T>,
	remove: (self: any, entity: T) -> Group<T>,
	removeBulk: (self: any, entities: { T }) -> Group<T>,
	clear: (self: any) -> Group<T>,

	setAutoClean: (self: any, enabled: boolean) -> Group<T>,
	getId: (self: any) -> number,
	getEntities: (self: any) -> { T },
	contains: (self: any, entity: T) -> boolean,
	iterEntities: (self: any) -> () -> T?,
	onDestroy: (self: any, callback: () -> ()) -> () -> (),
	destroy: (self: any) -> (),
}

export type InternalGroup<T = any> = Group<T> & {
	_add: (self: any, entity: T) -> Group<T>,
	_addBulk: (self: any, entities: { T }) -> Group<T>,
	_remove: (self: any, entity: T) -> Group<T>,
	_removeBulk: (self: any, entities: { T }) -> Group<T>,
	_clear: (self: any) -> Group<T>,
	id: number,
	entities: { T },
	entityIndices: { [any]: number },
	isManaged: boolean?,
	autoClean: boolean,
	onDestroyCallbacks: { () -> () }?,
}

export type GroupClass = {
	new: <T>(config: {
		entities: { T }?,
		autoClean: boolean?,
	}?) -> Group<T>,
	fromTag: (tag: string) -> Group<Entity>,
	players: () -> Group<Player>,
	localPlayer: () -> Group<Player>,
}

-- Zones

export type Zone<T = any> = {
	sync: (self: any) -> Zone<T>,
	setReference: (self: any, reference: T?) -> Zone<T>,
	setAutoSync: (self: any, autoSync: boolean) -> Zone<T>,
	setDynamic: (self: any, dynamic: boolean) -> Zone<T>,
	setCFrame: (self: any, cf: CFrame) -> Zone<T>,
	setPosition: (self: any, pos: Vector3) -> Zone<T>,
	setSize: (self: any, size: Vector3) -> Zone<T>,
	setShape: (self: any, shape: ShapeType) -> Zone<T>,
	setMetadata: (self: any, metadata: any?) -> Zone<T>,

	getMetadata: (self: any) -> any?,
	getId: (self: any) -> number,
	getReference: (self: any) -> T?,
	getPosition: (self: any) -> Vector3,
	getCFrame: (self: any) -> CFrame,
	getSize: (self: any) -> Vector3,
	getShape: (self: any) -> ShapeType,

	isDynamic: (self: any) -> boolean,
	isPointInside: (self: any, point: Vector3) -> boolean,

	onDestroy: (self: any, callback: () -> ()) -> () -> (),
	destroy: (self: any) -> (),
}

export type InternalZone<T = any> = Zone<T> & {
	attach: (self: any, observer: any) -> Zone<T>,
	detach: (self: any, observer: any) -> Zone<T>,

	id: number,
	reference: T?,
	dynamic: boolean,
	metadata: any?,
	autoSync: boolean,
	syncConnections: { RBXScriptConnection }?,
	onDestroyCallbacks: { () -> () }?,
}

export type Zones<T = any> = {
	sync: (self: any) -> Zones<T>,
	setAutoSync: (self: any, autoSync: boolean) -> Zones<T>,
	setDynamic: (self: any, dynamic: boolean) -> Zones<T>,
	getZones: (self: any) -> { Zone<T> },
	getMetadata: (self: any) -> any?,
	isDynamic: (self: any) -> boolean,
	isPointInside: (self: any, point: Vector3) -> boolean,
	setMetadata: (self: any, metadata: any?) -> Zones<T>,
	contains: (self: any, zone: Zone<T>) -> boolean,
	iterZones: (self: any) -> () -> Zone<T>?,
	getReferences: (self: any) -> { T },
	iterReferences: (self: any) -> () -> (T?, Zone<T>?),

	onDestroy: (self: any, callback: () -> ()) -> () -> (),
	destroy: (self: any) -> (),
}

export type InternalZones<T = any> = Zones<T> & {
	attach: (self: any, observer: any) -> Zones<T>,
	detach: (self: any, observer: any) -> Zones<T>,

	autoSync: boolean?,
	dynamic: boolean,
	metadata: any?,
	zones: { [any]: boolean },
	observers: { [any]: boolean },
	onDestroyCallbacks: { () -> () }?,
	onDestroyObserverCleanups: { [any]: () -> () },
	onDestroyZoneCleanups: { [any]: () -> () },
	add: (self: InternalZones<T>, zone: Zone<T>) -> (),
	remove: (self: InternalZones<T>, zone: Zone<T>) -> (),
}

export type ZoneClass = {
	new: <T>(
		config: {
			cframe: CFrame,
			size: Vector3,
			shape: ShapeType?,
			reference: T?,
			isDynamic: boolean?,
			metadata: any?,
			autoSync: boolean?,
		}
	) -> Zone<T>,
	fromPart: (
		part: BasePart,
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zone<BasePart>,
	fromParts: (
		parts: { BasePart },
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zones<BasePart>,
	fromTag: (
		tag: string,
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zones<BasePart>,
	fromDescendants: (
		parent: Instance,
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zones<BasePart>,
	fromChildren: (
		parent: Instance,
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zones<BasePart>,
}

-- Observer

export type Observer<T = any, Z = any> = {
	subscribe: (self: any, group: Group<T>) -> Observer<T, Z>,
	unsubscribe: (self: any, group: Group<T>) -> Observer<T, Z>,
	attach: (self: any, zone: Zone<Z> | Zones<Z>) -> Observer<T, Z>,
	detach: (self: any, zone: Zone<Z> | Zones<Z>) -> Observer<T, Z>,

	setPriority: (self: any, n: number) -> Observer<T, Z>,
	setUpdateRate: (self: any, hz: number) -> Observer<T, Z>,
	setPrecision: (self: any, n: number) -> Observer<T, Z>,
	setEnabled: (self: any, enabled: boolean) -> Observer<T, Z>,
	setSafety: (self: any, enabled: boolean) -> Observer<T, Z>,

	isEnabled: (self: any) -> boolean,
	isSafe: (self: any) -> boolean,
	isPointInside: (self: any, position: Vector3) -> boolean,

	getId: (self: any) -> number,
	getPriority: (self: any) -> number,
	getUpdateRate: (self: any) -> number,
	getPrecision: (self: any) -> number,
	getZones: (self: any) -> { Zone<Z> },
	getGroups: (self: any) -> { Group<T> },
	getEntitiesInside: (self: any) -> { T },
	getPlayersInside: (self: any) -> { Player },
	getZoneOfEntity: (self: any, entity: T) -> Zone<Z>?,
	getZoneOfPlayer: (self: any, player: Player) -> Zone<Z>?,
	getEntitiesInZone: (self: any, zone: Zone<Z>) -> { T },
	getPlayersInZone: (self: any, zone: Zone<Z>) -> { Player },

	iterZones: (self: any) -> () -> Zone<Z>?,
	iterGroups: (self: any) -> () -> Group<T>?,
	iterEntitiesInside: (self: any) -> () -> (T?, Zone<Z>?),
	iterPlayersInside: (self: any) -> () -> (Player?, Zone<Z>?),
	iterEntitiesInZone: (self: any, zone: Zone<Z>) -> () -> T?,
	iterPlayersInZone: (self: any, zone: Zone<Z>) -> () -> Player?,

	observe: (self: any, callback: (T, Zone<Z>) -> (() -> ())?) -> () -> (),
	observePlayer: (self: any, callback: (Player, Zone<Z>) -> (() -> ())?) -> () -> (),
	observeLocalPlayer: (self: any, callback: (Zone<Z>) -> (() -> ())?) -> () -> (),
	observeGroup: (self: any, callback: (Group<T>, Zone<Z>) -> (() -> ())?) -> () -> (),
	onEnter: (self: any, callback: (T, Zone<Z>) -> ()) -> () -> (),
	onExit: (self: any, callback: (T, Zone<Z>) -> ()) -> () -> (),
	onPlayerEnter: (self: any, callback: (Player, Zone<Z>) -> ()) -> () -> (),
	onPlayerExit: (self: any, callback: (Player, Zone<Z>) -> ()) -> () -> (),
	onLocalPlayerEnter: (self: any, callback: (Zone<Z>) -> ()) -> () -> (),
	onLocalPlayerExit: (self: any, callback: (Zone<Z>) -> ()) -> () -> (),
	onGroupEnter: (self: any, callback: (Group<T>, Zone<Z>) -> ()) -> () -> (),
	onGroupExit: (self: any, callback: (Group<T>, Zone<Z>) -> ()) -> () -> (),
	onTransition: (self: any, callback: (T, Zone<Z>) -> ()) -> () -> (),
	onPlayerTransition: (self: any, callback: (Player, Zone<Z>) -> ()) -> () -> (),
	onLocalPlayerTransition: (self: any, callback: (Zone<Z>) -> ()) -> () -> (),

	onDestroy: (self: any, callback: () -> ()) -> () -> (),
	destroy: (self: any) -> (),
}

export type ObserverClass = {
	new: <T, Z>(
		config: {
			groups: { Group<T> }?,
			zones: { Zone<Z> | Zones<Z> }?,
			priority: number?,
			updateRate: number?,
			precision: number?,
			enabled: boolean?,
			safety: boolean?,
		}?
	) -> Observer<T, Z>,
}

export type InternalObserver<T = any, Z = any> = Observer<T, Z> & {
	id: number,
	onDestroyCallbacks: { () -> () }?,
}

-- QuickZone

export type QuickZone = {
	Zone: ZoneClass,
	Observer: ObserverClass,
	Group: GroupClass,

	configure: (
		self: any,
		config: { enabled: boolean?, autoSyncRate: number?, frameBudget: number? }
	) -> QuickZone,
	setEnabled: (self: any, enabled: boolean) -> QuickZone,
	rebuild: (self: any) -> QuickZone,
	update: (self: any, dt: number) -> QuickZone,
	setFrameBudget: (self: any, ms: number) -> QuickZone,
	setReference: (self: any, reference: any?, entity: Entity?) -> QuickZone,
	visualize: (self: any, enabled: boolean) -> QuickZone,
	removeEntity: (self: any, entity: any) -> QuickZone,

	getEntityOfReference: (self: any, reference: any) -> Entity?,
	getReferenceOfEntity: (self: any, entity: Entity) -> any,
	getZones: (self: any) -> { Zone<any> },
	getObservers: (self: any) -> { Observer<any, any> },
	getGroups: (self: any) -> { Group<any> },
	getEntities: (self: any) -> { any },
	iterZones: (self: any) -> () -> Zone<any>?,
	iterObservers: (self: any) -> () -> Observer<any, any>?,
	iterGroups: (self: any) -> () -> Group<any>?,
	iterEntities: (self: any) -> () -> any?,
	getZonesAtPoint: (self: any, position: Vector3) -> { Zone<any> },
	iterZonesAtPoint: (self: any, position: Vector3) -> () -> Zone<any>?,
	getZonesOfEntity: (self: any, entity: any) -> { Zone<any> },
	iterZonesOfEntity: (self: any, entity: any) -> () -> Zone<any>?,
	getGroupsOfEntity: (self: any, entity: any) -> { Group<any> },
	iterGroupsOfEntity: (self: any, entity: any) -> () -> Group<any>?,
}

return nil
