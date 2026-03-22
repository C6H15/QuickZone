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

export type Zone = {
	sync: (self: any) -> Zone,
	setReference: (self: any, reference: (Attachment | BasePart | Bone)?) -> Zone,
	setAutoSync: (self: any, autoSync: boolean) -> Zone,
	setDynamic: (self: any, dynamic: boolean) -> Zone,
	setCFrame: (self: any, cf: CFrame) -> Zone,
	setPosition: (self: any, pos: Vector3) -> Zone,
	setSize: (self: any, size: Vector3) -> Zone,
	setShape: (self: any, shape: ShapeType) -> Zone,
	setMetadata: (self: any, metadata: any?) -> Zone,

	getMetadata: (self: any) -> any?,
	getId: (self: any) -> number,
	getReference: (self: any) -> (Attachment | BasePart | Bone)?,
	getPosition: (self: any) -> Vector3,
	getCFrame: (self: any) -> CFrame,
	getSize: (self: any) -> Vector3,
	getShape: (self: any) -> ShapeType,

	isDynamic: (self: any) -> boolean,
	isPointInside: (self: any, point: Vector3) -> boolean,

	onDestroy: (self: any, callback: () -> ()) -> () -> (),
	destroy: (self: any) -> (),
}

export type InternalZone = Zone & {
	attach: (self: any, observer: any) -> Zone,
	detach: (self: any, observer: any) -> Zone,

	id: number,
	reference: (Attachment | BasePart | Bone)?,
	dynamic: boolean,
	metadata: any?,
	autoSync: boolean,
	syncConnections: { RBXScriptConnection }?,
	onDestroyCallbacks: { () -> () }?,
}

export type Zones = {
	sync: (self: any) -> Zones,
	setAutoSync: (self: any, autoSync: boolean) -> Zones,
	setDynamic: (self: any, dynamic: boolean) -> Zones,
	getZones: (self: any) -> { Zone },
	getMetadata: (self: any) -> any?,
	isDynamic: (self: any) -> boolean,
	isPointInside: (self: any, point: Vector3) -> boolean,
	setMetadata: (self: any, metadata: any?) -> Zones,
	contains: (self: any, zone: Zone) -> boolean,
	iterZones: (self: any) -> () -> Zone?,
	getReferences: (self: any) -> { Attachment | BasePart | Bone },
	iterReferences: (self: any) -> () -> ((Attachment | BasePart | Bone)?, Zone?),

	onDestroy: (self: any, callback: () -> ()) -> () -> (),
	destroy: (self: any) -> (),
}

export type InternalZones = Zones & {
	attach: (self: any, observer: any) -> Zones,
	detach: (self: any, observer: any) -> Zones,

	autoSync: boolean?,
	dynamic: boolean,
	metadata: any?,
	zones: { [any]: boolean },
	observers: { [any]: boolean },
	onDestroyCallbacks: { () -> () }?,
	onDestroyObserverCleanups: { [any]: () -> () },
	onDestroyZoneCleanups: { [any]: () -> () },
	add: (self: InternalZones, zone: Zone) -> (),
	remove: (self: InternalZones, zone: Zone) -> (),
}

export type ZoneClass = {
	new: (
		config: {
			cframe: CFrame,
			size: Vector3,
			shape: ShapeType?,
			reference: (Attachment | BasePart | Bone)?,
			isDynamic: boolean?,
			metadata: any?,
			autoSync: boolean?,
		}
	) -> Zone,
	fromPart: (part: BasePart, config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?) -> Zone,
	fromParts: (
		parts: { BasePart },
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zones,
	fromTag: (tag: string, config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?) -> Zones,
	fromDescendants: (
		parent: Instance,
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zones,
	fromChildren: (
		parent: Instance,
		config: { isDynamic: boolean?, metadata: any?, autoSync: boolean? }?
	) -> Zones,
}

-- Observer

export type Observer<T = any> = {
	subscribe: (self: any, group: Group<T>) -> Observer<T>,
	unsubscribe: (self: any, group: Group<T>) -> Observer<T>,
	attach: (self: any, zone: Zone | Zones) -> Observer<T>,
	detach: (self: any, zone: Zone | Zones) -> Observer<T>,

	setPriority: (self: any, n: number) -> Observer<T>,
	setUpdateRate: (self: any, hz: number) -> Observer<T>,
	setPrecision: (self: any, n: number) -> Observer<T>,
	setEnabled: (self: any, enabled: boolean) -> Observer<T>,
	setSafety: (self: any, enabled: boolean) -> Observer<T>,

	isEnabled: (self: any) -> boolean,
	isSafe: (self: any) -> boolean,
	isPointInside: (self: any, position: Vector3) -> boolean,

	getId: (self: any) -> number,
	getPriority: (self: any) -> number,
	getUpdateRate: (self: any) -> number,
	getPrecision: (self: any) -> number,
	getZones: (self: any) -> { Zone },
	getGroups: (self: any) -> { Group<T> },
	getEntitiesInside: (self: any) -> { T },
	getPlayersInside: (self: any) -> { Player },
	getZoneOfEntity: (self: any, entity: T) -> Zone?,
	getZoneOfPlayer: (self: any, player: Player) -> Zone?,
	getEntitiesInZone: (self: any, zone: Zone) -> { T },
	getPlayersInZone: (self: any, zone: Zone) -> { Player },

	iterZones: (self: any) -> () -> Zone?,
	iterGroups: (self: any) -> () -> Group<T>?,
	iterEntitiesInside: (self: any) -> () -> (T?, Zone?),
	iterPlayersInside: (self: any) -> () -> (Player?, Zone?),
	iterEntitiesInZone: (self: any, zone: Zone) -> () -> T?,
	iterPlayersInZone: (self: any, zone: Zone) -> () -> Player?,

	observe: (self: any, callback: (T, Zone) -> (() -> ())?) -> () -> (),
	observePlayer: (self: any, callback: (Player, Zone) -> (() -> ())?) -> () -> (),
	observeLocalPlayer: (self: any, callback: (Zone) -> (() -> ())?) -> () -> (),
	observeGroup: (self: any, callback: (Group<T>, Zone) -> (() -> ())?) -> () -> (),
	onEnter: (self: any, callback: (T, Zone) -> ()) -> () -> (),
	onExit: (self: any, callback: (T, Zone) -> ()) -> () -> (),
	onPlayerEnter: (self: any, callback: (Player, Zone) -> ()) -> () -> (),
	onPlayerExit: (self: any, callback: (Player, Zone) -> ()) -> () -> (),
	onLocalPlayerEnter: (self: any, callback: (Zone) -> ()) -> () -> (),
	onLocalPlayerExit: (self: any, callback: (Zone) -> ()) -> () -> (),
	onGroupEnter: (self: any, callback: (Group<T>, Zone) -> ()) -> () -> (),
	onGroupExit: (self: any, callback: (Group<T>, Zone) -> ()) -> () -> (),
	onTransition: (self: any, callback: (T, Zone) -> ()) -> () -> (),
	onPlayerTransition: (self: any, callback: (Player, Zone) -> ()) -> () -> (),
	onLocalPlayerTransition: (self: any, callback: (Zone) -> ()) -> () -> (),

	onDestroy: (self: any, callback: () -> ()) -> () -> (),
	destroy: (self: any) -> (),
}

export type ObserverClass = {
	new: <T>(
		config: {
			groups: { Group<T> }?,
			zones: { Zone | Zones }?,
			priority: number?,
			updateRate: number?,
			precision: number?,
			enabled: boolean?,
			safety: boolean?,
		}?
	) -> Observer<T>,
}

export type InternalObserver<T = any, Z = any> = Observer<T> & {
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
	getZones: (self: any) -> { Zone },
	getObservers: (self: any) -> { Observer<any> },
	getGroups: (self: any) -> { Group<any> },
	getEntities: (self: any) -> { any },
	iterZones: (self: any) -> () -> Zone?,
	iterObservers: (self: any) -> () -> Observer<any>?,
	iterGroups: (self: any) -> () -> Group<any>?,
	iterEntities: (self: any) -> () -> any?,
	getZonesAtPoint: (self: any, position: Vector3) -> { Zone },
	iterZonesAtPoint: (self: any, position: Vector3) -> () -> Zone?,
	getZonesOfEntity: (self: any, entity: any) -> { Zone },
	iterZonesOfEntity: (self: any, entity: any) -> () -> Zone?,
	getGroupsOfEntity: (self: any, entity: any) -> { Group<any> },
	iterGroupsOfEntity: (self: any, entity: any) -> () -> Group<any>?,
}

return nil
