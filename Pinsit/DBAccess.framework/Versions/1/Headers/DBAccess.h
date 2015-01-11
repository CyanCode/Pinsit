//
//  DBAccess.h
//
//  Created by Adrian Herridge on 14/12/2010.
/*
 
Copyright (C) 2010 iPresent inc. All rights reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

#define DB_ACCESS_DATE              20141012
#define DB_ACCESS_VER               1.05.8

#import <Foundation/Foundation.h>
#import <objc/message.h>

@class DBObject;
@class DBRelationship;
@class DBEvent;
@class DBEventHandler;
@class DBQuery;
@class DBTransaction;

/*
 *  DBTransactionMacro
 */

#define DBTransaction(code)\
do { \
id transaction = objc_msgSend(NSClassFromString(@"DBTransactionCollection"), NSSelectorFromString(@"createEffectiveCollection"));\
code;\
if(objc_msgSend(transaction, NSSelectorFromString(@"commitTransaction"))){}\
objc_msgSend(NSClassFromString(@"DBTransactionCollection"), NSSelectorFromString(@"clearEffectiveTransaction"));\
} while(0);

#define DBTransactionWithRollback(code,rollback)\
do { \
id transaction = objc_msgSend(NSClassFromString(@"DBTransactionCollection"), NSSelectorFromString(@"createEffectiveCollection"));\
code;\
if(!objc_msgSend(transaction, NSSelectorFromString(@"commitTransaction"))){rollback;}\
objc_msgSend(NSClassFromString(@"DBTransactionCollection"), NSSelectorFromString(@"clearEffectiveTransaction"));\
} while(0);

typedef void(^DBTransactionBlockBlock)();

/**
 * DBTransaction class, for wrapping multiple insert/update/delete commands within a single operation.
 */
@interface DBTransaction : NSObject

/**
 * Creates a new transaction for the current executing thread, which then executes the transaction block that was passed into the object, if the transaction failes in anypart the database changes are rolled back and the rollback block is called.
 * @author Adrian Herridge
 *
 * @param transaction:(DBTransactionBlockBlock*)transaction A valid DBTransactionBlockBlock, any objects which are commited to removed within this block, will be dealt with within a single transaction.
 * @param withRollback:(DBTransactionBlockBlock*)rollback A valid DBTransactionBlockBlock, if executed all database objects are restored back to their previos state before the transaction began.
 * @return void
 */
+ (void)transaction:(DBTransactionBlockBlock)transaction withRollback:(DBTransactionBlockBlock)rollback;

@end

/**
 * Create a valid 'LIKE' parameter neatly, DBAccess will then recognise this and construct the correct parameter within the query.
 * @author Adrian Herridge
 *
 * @param param The string value that you wish to use within a LIKE condition.
 * @return A newly created string which is formatted as a valid LIKE statement, e.g. @" '%{value}%' ".
 */
NSString* dbMakeLike(NSString* param);

typedef enum {
    DB_RELATE_ONETOONE = 1,
    DB_RELATE_ONETOMANY = 2,
    DB_RELATE_MANYTOMANY = 3,
} DBRelationshipType;


/**
 * Settings class for DBAccess, returned from the delegate when the engine is initialized.
 * @author Adrian Herridge
 */
@interface DBAccessSettings : NSObject

/// when TRUE all dates are stored within the system as numbers for performance reasons instead of ANSI date strings.
@property BOOL                      useHighPerformanceDates;
/// The SQLite standard journaling mode that will be used on all connections, the defalut is WAL.
@property (strong) NSString*        sqliteJournalingMode;
/// when TRUE, all objects created will automatically be registered within the default managed object domain, this will save the developer from having to manually add the parameter to any queries or individually to objects.
@property BOOL                      defaultManagedObjects;
/// the default managed object domain used for new objects when defaultManagedObjects is set to TRUE.  If not set, this defaults to "dbaccess.default"
@property (strong)                  NSString* defaultManagedObjectDomain;
/// stores the location that the database is located or created in.
@property (nonatomic,strong)        NSString* databaseLocation;
/// the filename of the default database file, e.g. "MyApplication".  DBAccess will automatically append ."db" onto the end of the filename.
@property (nonatomic,strong)        NSString* defaultDatabaseName;
/// this is the AES256 encryption key that is used when properties are specified as encryptable.
@property (strong)                  NSString* encryptionKey;
/// tells DBAccess if you wish to retain values for lightweight objects once they are done with.
@property BOOL                      retainLightweightObjects;

@end

/**
 * Contains performance anaylsis information about a query that was performed by the system.
 * @author Adrian Herridge
 */
@interface DBQueryProfile : NSObject

/// The number of rows returned by the query.
@property  int rows;
/// The time it took to parse the query before executing it.
@property  int parseTime;
/// The seek time to the first record, usually an indication of a value in the query not being indexed.  But also includes other overheads when DBAccess has to check the cache or load an index.
@property  int firstResultTime;
/// The overall time it took to perform the query, excluding the subsequent time it took to analyse the performance and gain extra information from an EXPLAIN statement.
@property  int queryTime;
/// The time (in ms) it took to gain an appropriate lock on the database to perform the query, this is often symptomatic of many competing threads looking to gain exclusive access to a table at the same time.
@property  int lockObtainTime;
/// The query plan as returned by SQLite
@property  (nonatomic, strong) NSArray* queryPlan;
/// The query that was generated from the DBQuery object.
@property  (nonatomic, strong) NSString* sqlQuery;
/// The compiled query with teh parameters included.
@property  (nonatomic, strong) NSString* compiledQuery;
/// The resultant output from the query.
@property  (nonatomic, strong) NSObject* resultsSet;

@end

/**
 * Ad error raised by DBAccess, gives you the message from the core, as well as the SQL query that was generated and caused the fault.
 * @author Adrian Herridge
 */
@interface DBError : NSObject

/// The error message that was returned from the core of DBAccess.
@property  (nonatomic, retain)  NSString* errorMessage;
/// The query that caused the error.
@property  (nonatomic, retain)  NSString* sqlQuery;

@end

@protocol DBDelegate <NSObject>

@optional

/// Retuen a DBAccessSettings* object to override the default settings, this will be asked for on initialization of the first persistable object.
- (DBAccessSettings*)getCustomSettings;
/// This method is called when the database has been successfully opened.
- (void)databaseOpened;
/// This method is called when an error occours within DBAccess.
- (void)databaseError:(DBError*)error;
/// This method, if implemented, will profile all queries that are performed within DBAccess.  Use the queryTime property within the DBQueryProfile* object to filter out only queries that do not meet your performance requirements.
- (void)queryPerformedWithProfile:(DBQueryProfile*)profile;
/// Called whenever an object is removed form the database.
- (BOOL)onDelete:(DBObject*)entity;
/// Called whenever an existing object is re-written into the database.
- (BOOL)onUpdate:(DBObject*)entity;
/// Called when a new object is commited for the first time into the database.
- (BOOL)onInsert:(DBObject*)entity;
/// An object that did not support a valid encoding mechanisum was attempted to be written to the database.  It is therefore passed to the delegate method for encoding.  You must return an NSData object that can be stored and later re-hydrated by a call to "decodeUnsupportedColumnValueForColumn"
- (NSData*)encodeUnsupportedColumnValueForColumn:(NSString*)column inEntity:(NSString*)entity value:(id)value;
/// Previously an object was persistsed that was not supported by DBAccess, and "encodeUnsupportedColumnValueForColumn" was called to encode it into a NSData* object, this metthod will pass back a hydrated object created from the NSData*
- (id)decodeUnsupportedColumnValueForColumn:(NSString*)column inEntity:(NSString*)entity data:(NSData*)value;

@end

/**
 * DBAccess class, always accessed through class methods, there is only ever a single instance of the database engine.
 * @author Adrian Herridge
 */
@interface DBAccess : NSObject {
    
}

/**
 * Sets the DBDelegate object that will be used by DBAccess to gain access to settings and to provide the deleoper with access to feedback.
 * @author Adrian Herridge
 *
 * @param aDelegate Must be an initialised object that implements the DBDelegate protocol.
 * @return void
 */
+(void)setDelegate:(id<DBDelegate>)aDelegate;
/**
 * Used to pre-create and update any persistable classes, DBAccess by default, will only create or update the schema with objects when they are first referenced.  If there is a requirement to ensure that a collection of classes are created before they are used anywhere then you can use this method.  This is not required in most scenarios.
 * @author Adrian Herridge
 *
 * @param (Class)class Array of Class* objects to be initialized
 * @return void
 */
+(void)setupTablesFromClasses:(Class)class,...;
/**
 * Migrates data from an existing CoreData database file into DBAccess, only the supplied object names are converted.  NOTE: If successful, the original file will be removed by the routine.  Existing Objects within the supplied list will be cleared from the database.
 * @author Adrian Herridge
 *
 * @param filePath The full path to the CoreData file that needs to be converted.
 * @param tablesToConvert Array of DBObject class names to convert from the original CoreData file provided.
 * @return void
 */
+(void)migrateFromLegacyCoredataFile:(NSString*)filePath tables:(NSArray*)tablesToConvert;
/**
 * Opens or creates a database file from the given name.
 * @author Adrian Herridge
 *
 * @param dbName The name of the database to open or create, this is not the full path to the object. By default the path defaults to the applcations Documents directory. If you wish to modify the path the file will exist in, then you will need to implement the "getCustomSettings" delegate method and return an alternative path.
 * @return void;
 */
+(void)openDatabaseNamed:(NSString*)dbName;

@end

/*
 *      DBRelationship
 */

@interface DBRelationship : NSObject {
    
}

@property Class                             sourceClass;
@property Class                             targetClass;
@property (nonatomic, strong) NSString*     sourceProperty;
@property (nonatomic, strong) NSString*     targetProperty;
@property (nonatomic, strong) NSString*     linkTable;
@property (nonatomic, strong) NSString*     linkSourceField;
@property (nonatomic, strong) NSString*     linkTargetField;
@property (nonatomic, strong) NSString*     entityPropertyName;
@property (nonatomic, strong) NSString*     order;
@property (nonatomic, strong) NSString*     restrictions;
@property int                               relationshipType;

@end

/*
 *      DBIndexDefinition
 */

enum DBIndexSortOrder {
    DBIndexSortOrderAscending = 1,
    DBIndexSortOrderDescending = 2,
    DBIndexSortOrderNoCase = 3
    };

/**
 * Used to define a set of indexes within a persitable object.
 * @author Adrian Herridge
 */
@interface DBIndexDefinition : NSObject {
    
}
/**
 * Adds the definition for an index on a given object.
 * @author Adrian Herridge
 *
 * @param propertyName The name of the property that you wish to index.
 * @param propertyOrder The order of the index, specified as a value of enum DBIndexSortOrder.
 * @return void
 */
- (void)addIndexForProperty:(NSString*)propertyName propertyOrder:(enum DBIndexSortOrder)propOrder;
/**
 * Adds a composite index on a given object with a sub index on an additional property.
 * @author Adrian Herridge
 *
 * @param propertyName The name of the property that you wish to index.
 * @param propertyOrder The order of the index, specified as a value of enum DBIndexSortOrder.
 * @param secondaryProperty The name of the second property that you wish to index.
 * @param secondaryOrder The order of the index, specified as a value of enum DBIndexSortOrder.
 * @return void
 */
- (void)addIndexForProperty:(NSString*)propertyName propertyOrder:(enum DBIndexSortOrder)propOrder secondaryProperty:(NSString*)secProperty secondaryOrder:(enum DBIndexSortOrder)secOrder;

@end

@protocol DBPartialClassDelegate

@required
/**
 * If implemented, DBAccess knows that this class is only a partial implementation of an existing DBObject derrived class.  These objects can be retrieved, but will remain sterile and cannot be commited back into the original table.
 * @author Adrian Herridge
 *
 * @return (Class) The original DBObject derrived class definition on which this object is partially based.
 */
+ (Class)classIsPartialImplementationOfClass;

@end

enum DBAccessEvent {
    DBAccessEventInsert = 1,
    DBAccessEventUpdate = 2,
    DBAccessEventDelete = 4,
};

typedef void(^DBEventRegistrationBlock)(DBEvent* event);

/**
 * If implemented, DBEventDelegate is used to notify an object that an event has been raised within a DBObject.
 * @author Adrian Herridge
 */
@protocol DBEventDelegate <NSObject>

@required
/**
 * Called when a DBObject class raises an INSERT, UPDATE or DELETE trigger.  This will only get called after the successful completion of the transaction within the database engine.
 * @author Adrian Herridge
 *
 * @param (DBEvent*)e The event object that was created from the DBAccess event model.
 * @return void
 */
- (void)DBObjectDidRaiseEvent:(DBEvent*)e;

@end

/*
 *      DBResultSet
 */
/**
 * Contains the results from a fetch call to a DBQuery object.  Subclassed from an NSArray, it contains two extra methods, removeAll & commitAll.  These are optimized to complete within a single transaction.
 * @author Adrian Herridge
 */
@interface DBResultSet : NSArray
/**
 * Removes all objects contained within the array from the database.  This is done within a single transaction to optimize performance.
 * @author Adrian Herridge
 *
 * @return void
 */
- (void)removeAll;

@end

/*
 *      DBContext
 */

typedef     void(^contextExecutionBlock)();

/**
 * DBContext objects are used to effect bulk operations across single or multiple tables.  You can not call commit on an object that has been added to a context.  Instead you call commit on the context itself, all activities will then be performed within an single transaction. NOTE: all DBObjects have their own context already, and any activity performed on then is guaranteed to complete in an ATOMIC way.  This style of object management is provided in a legacy manner as this is a method that programmers are largely used to, but it is not a requirement.  DBAccess already groups together operations and performs them in bulk when it can to improve performance, the deleoper does not need to think about this when writing their application.
 * @author Adrian Herridge
 */
@interface DBContext : NSObject
/**
 * Adds an DBObject to a context.
 * @author Adrian Herridge
 *
 * @param (DBObject*)entity The entity to add to the context.
 * @return void
 */
- (void)addEntityToContext:(DBObject*)entity;
/**
 * Removes an DBObject from a context.
 * @author Adrian Herridge
 *
 * @param (DBObject*)entity The entity to be removed from the context.
 * @return void
 */
- (void)removeEntityFromContext:(DBObject*)entity;
/**
 * Used to test if an object is already a member of this context.
 * @author Adrian Herridge
 *
 * @param (DBObject*)entity The entity to be tested for its presence.
 * @return BOOL returns YES if this object exists in this context.
 */
- (BOOL)isEntityInContext:(DBObject*)entity;
/**
 * Commits all of the pending changes contained in DBObject's within the context.
 * @author Adrian Herridge
 *
 * @return BOOL returns YES if the operation was successful.
 */
- (BOOL)commit;

@end

/*
 *      DBObject
 *
 */

/**
 * Specifies a persistable class within DBAccess, any properties that are created within a class that is derrived from DBObject will need to implemnted using dynamic properties and not synthesized.  DBAccess places its own get/set methods to ensure that all values are correct for the storage and column type.
 * @author Adrian Herridge
 */
@interface DBObject : NSObject <NSCopying>

/// Creates a DBQuery object for this class
+ (DBQuery*)query;
/// Returns the first object where th eproperty is matched with value
+ (id)firstMatchOf:(NSString*)property withValue:(id)value;

/// The event object for the entire class.
+ (DBEventHandler*)eventHandler;

/// The primary key column, this is common and mandatory across all persistable classes.
@property (nonatomic, strong)   NSNumber* Id;

/// Joined data, if set this contains the results of the query from adjoining tables
@property (nonatomic, strong)   NSDictionary* joinedResults;

/**
 * Initialises a new instance of the object, if an object already exists with the specified primary key then you will get that object back, if not you will net a new object with the primary key specified already.
 * @author Adrian Herridge
 *
 * @param (NSObject*)priKeyValue The primary key value to look up an existing object
 * @return DBObject* Either an existing or new class.
 */
- (id)initWithPrimaryKeyValue:(NSObject*)priKeyValue;
/**
 * Removes the object form the database
 * @author Adrian Herridge
 *
 * @return BOOL returns NO if the operation failed to complete.
 */
- (BOOL)remove;
/**
 * Inserts or updates the object within the database.
 * @author Adrian Herridge
 *
 * @return BOOL returns NO if the operation failed to complete.
 */
- (BOOL)commit;

/* these methods should be overloaded in the business object class */
/**
 * Before DBAccess attempts an operation it will ask the persitable class if it would like to continue with this operation.
 * @author Adrian Herridge
 *
 * @return BOOL if YES is returned then DBAccess WILL complete the operation and it is guaranteed to complete.  All pre-requisite checks have been made and the statement compiled before getting to this point.  It is safe to use this method to cascade operations to other classes.
 */
- (BOOL)entityWillInsert;
/**
 * Before DBAccess attempts an operation it will ask the persitable class if it would like to continue with this operation.
 * @author Adrian Herridge
 *
 * @return BOOL if YES is returned then DBAccess WILL complete the operation and it is guaranteed to complete.  All pre-requisite checks have been made and the statement compiled before getting to this point.  It is safe to use this method to cascade operations to other classes.
 */
- (BOOL)entityWillUpdate;
/**
 * Before DBAccess attempts an operation it will ask the persitable class if it would like to continue with this operation.
 * @author Adrian Herridge
 *
 * @return BOOL if YES is returned then DBAccess WILL complete the operation and it is guaranteed to complete.  All pre-requisite checks have been made and the statement compiled before getting to this point.  It is safe to use this method to cascade operations to other classes. In the case of delete, you might wish to delete related records, or indeed remove this object from related tables.
 */
- (BOOL)entityWillDelete;
/**
 * Called after DBAccess has completed an action.
 * @author Adrian Herridge
 *
 * @return void
 */
- (void)entityDidInsert;
/**
 * Called after DBAccess has completed an action.
 * @author Adrian Herridge
 *
 * @return void
 */
- (void)entityDidUpdate;
/**
 * Called after DBAccess has completed an action.
 * @author Adrian Herridge
 *
 * @return void
 */
- (void)entityDidDelete;
/**
 * Used to specify the relationships between objects.  The class will be asked to return the relationship object for a certain property.
 * @author Adrian Herridge∫
 *
 * @param (NSString*)property The name of the property on the class that DBAccess is asking for clarification of its relationship with other objects.
 * @return (DBRelationship*) The relationship object should fully exlain the connection between the property and other objects.  If you return nil then DBAccess will assume that this property is not related to other objects and it will be persisted as a normal field.
 */
+ (DBRelationship*)relationshipForProperty:(NSString*)property;
/**
 * Used to specify the indexes that need to be created and maintained on the given object.
 * @author Adrian Herridge
 *
 * @return (DBIndexDefinition*) return an index object to let DBAccess know which properties need to be indexed for performance reasons.  Primary keys are already indexed, as are any properties that are in fact other persisbale classes.  DBAccess will attempt to automatically calculate indexes from the relationships between your classes, but sometimes you may with to add them manually given feedback form the profiling mechanisum.
 */
+ (DBIndexDefinition*)indexDefinitionForEntity;
/**
 * Specifies the properties on the class that should remain encrypted within the database. NOTE: you will not be able to perform optimised queries on these encrypted properties so they should only be used to encrypt sensitive data that would not normally be searched on.
 * @author Adrian Herridge
 *
 * @return and (NSArray*) of property names that DBAccess should keep encrypted in the database.
 */
+ (NSArray*)encryptedPropertiesForClass;
/**
 * Specifies the database file that this particular class will be persisted in.  This enables you to have your persistable classes spanning many different files.
 * @author Adrian Herridge
 *
 * @return (NSString*) alternative filename for storage of this class.ß
 */
+ (NSString*)storageDatabaseForClass;

/* partial classes */
+ (Class)classIsPartialImplementationOfClass;

/* live objects */
/**
 * Allows the developer to 'hook' into the events that are raised within DBAccess, useful if you wish to be notified when various actions happen within certain tables.
 * @author Adrian Herridge
 *
 * @param registerBlockForEvents:(enum DBAccessEvent)events specifies the events that you are looking to observe, these can be DBAccessEventInsert, DBAccessEventUpdate or DBAccessEventDelete.  They are bitwise properties so can be combined such like DBAccessEventInsert|DBAccessEventUpdate.
 * @param withBlock:(DBEventRegistrationBlock)block is the block to be executed when the event occours, this will be called on the main thread.
 * @return void
 */
- (void)registerBlockForEvents:(enum DBAccessEvent)events withBlock:(DBEventRegistrationBlock)block;
/**
 * Allows the developer to 'hook' into the events that are raised within DBAccess, useful if you wish to be notified when various actions happen within certain tables.
 * @author Adrian Herridge
 *
 * @param registerBlockForEvents:(enum DBAccessEvent)events specifies the events that you are looking to observe, these can be DBAccessEventInsert, DBAccessEventUpdate or DBAccessEventDelete.  They are bitwise properties so can be combined such like DBAccessEventInsert|DBAccessEventUpdate.
 * @param withBlock:(DBEventRegistrationBlock)block is the block to be executed when the event occours.
 * @param onMainThread:(BOOL)mainThread is used to specify if you wish the block to be executed on the main thread or the originating thread of the event.  Useful if you are updating UI componets.
 * @return void
 */
- (void)registerBlockForEvents:(enum DBAccessEvent)events withBlock:(DBEventRegistrationBlock)block onMainThread:(BOOL)mainThread;
/**
 * Allows the developer to 'hook' into the events that are raised within DBAccess, useful if you wish to be notified when various actions happen within certain tables.
 * @author Adrian Herridge
 *
 * @param registerBlockForEvents:(enum DBAccessEvent)events specifies the events that you are looking to observe, these can be DBAccessEventInsert, DBAccessEventUpdate or DBAccessEventDelete.  They are bitwise properties so can be combined such like DBAccessEventInsert|DBAccessEventUpdate.
 * @param withBlock:(DBEventRegistrationBlock)block is the block to be executed when the event occours.
 * @param onMainThread:(BOOL)mainThread is used to specify if you wish the block to be executed on the main thread or the originating thread of the event.  Useful if you are updating UI componets.
 * @param updateSelfWithEvent:(BOOL)updateSelf is used to specify if you wish the object to have its values updated with the changes that raised the event.
 * @return void
 */
- (void)registerBlockForEvents:(enum DBAccessEvent)events withBlock:(DBEventRegistrationBlock)block onMainThread:(BOOL)mainThread updateSelfWithEvent:(BOOL)updateSelf;
/**
 * Allows an object to become a member of a managed object domain, only objects within the same domain recieve value change notifications.
 * @author Adrian Herridge
 * @param setManagedObjectDomain:(NSString*)domain  sets the domain that this object is managed within, idetical objects within the same domain will share property values which are updated when the objects are comitted to the store.
 * @return void
 */
- (void)setManagedObjectDomain:(NSString*)domain;
/**
 * Clears all event blocks within the object and stops the object from receiving event notifications.
 * @author Adrian Herridge
 *
 * @return void
 */
- (void)clearAllRegisteredBlocks;

@end

/**
 * Every DBObject class or instance contains an DBEventHandler, which the developer can use to monitor activity within the object or class of objects.
 * @author Adrian Herridge
 *
 */
@interface DBEventHandler : NSObject

- (DBEventHandler*)entityclass:(Class)entityClass;

@property (nonatomic, weak) id<DBEventDelegate> delegate;
/**
 * Allows the developer to 'hook' into the events that are raised within DBAccess, useful if you wish to be notified when various actions happen within certain tables.
 * @author Adrian Herridge
 *
 * @param registerBlockForEvents:(enum DBAccessEvent)events specifies the events that you are looking to observe, these can be DBAccessEventInsert, DBAccessEventUpdate or DBAccessEventDelete.  They are bitwise properties so can be combined such like DBAccessEventInsert|DBAccessEventUpdate.
 * @param withBlock:(DBEventRegistrationBlock)block is the block to be executed when the event occours.
 * @param onMainThread:(BOOL)mainThread is used to specify if you wish the block to be executed on the main thread or the originating thread of the event.  Useful if you are updating UI componets.
 * @return void
 */
- (void)registerBlockForEvents:(enum DBAccessEvent)events withBlock:(DBEventRegistrationBlock)block onMainThread:(BOOL)mainThread;
/**
 * Clears all event blocks within the object and stops the object from receiving event notifications.
 * @author Adrian Herridge
 *
 * @return void
 */
- (void)clearAllRegisteredBlocks;

@end

/**
 * DBEvent* is an container class, which is passed to event objects as a parameter.
 * @author Adrian Herridge
 *
 */
@interface DBEvent : NSObject

/// The type of event that triggered the creation of this object
@property  enum DBAccessEvent               event;
/// The persistable object that created this event
@property  (nonatomic, weak) DBObject*      entity;
/// The properties that have changed within this object since its last comital into the database.
@property  (nonatomic, strong) NSArray*     changedProperties;

@end

/**
 *  DBAsyncHandler* is the event handler for async queries, allows them to be canceled and for progress to be reported.
 *
 *
 */
@interface DBQueryAsyncHandler : NSObject

/**
 * Cancels an in progress query.  If called on an expired query that has already completed then it will have no effect.
 * @author Adrian Herridge
 *
 * @return void
 */
- (void)cancelQuery;

@end

typedef void(^DBQueryAsyncResponse)(DBResultSet* results);

/**
 * A DBQuery class is used to construct a query object and return results from the database.
 * @author Adrian Herridge
 *
 *
 */

@interface DBQuery : NSObject

/* parameter methods */
/**
 * Specifies the WHERE clause of the query statement
 * @author Adrian Herridge
 *
 * @param (NSString*)where contains the parameters for the query, e.g. " forename = 'Adrian' AND isEmployee = 1 "
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)where:(NSString*)where;
/**
 * Specifies the WHERE clause of the query statement, using a standard format string.
 * @author Adrian Herridge
 *
 * @param (NSString*)where contains the parameters for the query, e.g. where:@" forename = %@ ", @"Adrian"
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)whereWithFormat:(NSString*)format,...;
/**
 * Specifies the WHERE clause of the query statement, using a standard format string.
 * @author Adrian Herridge
 *
 * @param (NSString*)where contains the parameters for the query, e.g. where:@" forename = %@ "
 * @param (NSArray*)params is an array of parameters to be placed into the format string, useful for constructing queries through a logic path.
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)whereWithFormat:(NSString*)format withParameters:(NSArray*)params;
/**
 * Limits the number of results retuned from the query
 * @author Adrian Herridge
 *
 * @param (int)limit the number of results to limit to
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)limit:(int)limit;
/**
 * Specifies the property by which the results will be ordered.  This can contain multiple, comma separated, values.
 * @author Adrian Herridge
 *
 * @param (NSString*)order a comma separated string for use to order the results, e.g. "surname, forename"
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)orderBy:(NSString*)order;
/**
 * Specifies the property by which the results will be ordered in decending value.  This can contain multiple, comma separated, values.
 * @author Adrian Herridge
 *
 * @param (NSString*)order a comma separated string for use to order the results, e.g. "surname, forename"
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)orderByDescending:(NSString*)order;
/**
 * Specifies the number of results to skip over before starting the aggregation of the results.
 * @author Adrian Herridge
 *
 * @param (int)offset the offset value for the query.
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)offset:(int)offset;
/**
 * Specifies the managed object domain that the query results will be added to.
 * @author Adrian Herridge
 *
 * @param (NSString*)domain the domain value as a string, e.g. "network-objects"
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)domain:(NSString*)domain;
/**
 * Used to include "joined" data within the query string, you must use the tablename.columnname syntax within a where statement
 * @author Adrian Herridge
 *
 * @param (Class)joinTo the class you would like to pwrform a SQL JOIN with
 * @param (NSString*)leftParameter the property name that you would like to use within the local object to match against the target
 * @param (NSString*)targetParameter the property within the class you wish to join with that will be matched with the left parameter.
 * @return (DBQuery*) this value can be discarded or used to nest queries together to form clear and concise statements.
 */
- (DBQuery*)joinTo:(Class)joinClass leftParameter:(NSString*)leftParameter targetParameter:(NSString*)targetParameter;

/* execution methods */
/**
 * Performs the query and returns the results, you will always get an object back even if there are no results.
 * @author Adrian Herridge
 *
 * @return (DBResultSet*) results of the query.  Always returns an object and never returns nil.
 */
- (DBResultSet*)fetch;
/**
 * Performs the query and returns the results, you will always get an object back even if there are no results.  All the objects will be deflated lightweight objects, who's values will only be retrieved upon accessing the properties.  If configured, the object can "hang on" to the object to stop repeat queries, but the objects will then use more memory.
 * @author Adrian Herridge
 *
 * @return (DBResultSet*) results of the query.  Always returns an object and never returns nil.
 */
- (DBResultSet*)fetchLightweight;
/**
 * Performs the query and returns the results, you will always get an object back even if there are no results.  All the objects will be deflated lightweight objects, who's values will only be retrieved upon accessing the properties.  If configured, the object can "hang on" to the object to stop repeat queries, but the objects will then use more memory.
 * @author Adrian Herridge
 * @param prefetchProperties:(NSArray*) the properties you would like to retieve with the fetch.
 *
 * @return (DBResultSet*) results of the query.  Always returns an object and never returns nil.
 */
- (DBResultSet*)fetchLightweightPrefetchingProperties:(NSArray*)properties;
/**
 * Performs the query as an async operation and returns a handler object. The results are then passed into the supplied DBQueryAsyncResponse block.
 * @author Adrian Herridge
 *
 * @return (DBQueryAsyncHandler*) an async query handler to allow the cancellation of the fetch request.
 */
- (DBQueryAsyncHandler*)fetchAsync:(DBQueryAsyncResponse)_responseBlock;
/**
 * Performs the query as an async operation and returns a handler object. The results are then passed into the supplied DBQueryAsyncResponse block.
 * @author Adrian Herridge
 * @param onMainThread: specify weather you want to execute the results block on the main thread.
 *
 * @return (DBQueryAsyncHandler*) an async query handler to allow the cancellation of the fetch request.
 */
- (DBQueryAsyncHandler *)fetchAsync:(DBQueryAsyncResponse)_responseBlock onMainThread:(BOOL)onMainThread;
/**
 * Performs the query and returns only the primary keys (Id parameter).  This is often much quicker if the fully hydrated objects are not required.
 * @author Adrian Herridge
 *
 * @return (NSArray*) primary keys of the query.
 */
/**
 * Performs the query and returns the results, you will always get an object back even if there are no results.  All the objects will be deflated lightweight objects, who's values will only be retrieved upon accessing the properties.  If configured, the object can "hang on" to the object to stop repeat queries, but the objects will then use more memory.
 * @author Adrian Herridge
 *
 * @return (DBResultSet*) results of the query.  Always returns an object and never returns nil.
 */
- (DBQueryAsyncHandler*)fetchLightweightAsync:(DBQueryAsyncResponse)_responseBlock onMainThread:(BOOL)onMainThread;
/**
 * Performs the query and returns the results, you will always get an object back even if there are no results.  All the objects will be deflated lightweight objects, who's values will only be retrieved upon accessing the properties.  If configured, the object can "hang on" to the object to stop repeat queries, but the objects will then use more memory.
 * @author Adrian Herridge
 * @param prefetchProperties:(NSArray*) the properties you would like to retieve with the fetch.
 *
 * @return (DBResultSet*) results of the query.  Always returns an object and never returns nil.
 */
- (DBQueryAsyncHandler*)fetchLightweightPrefetchingPropertiesAsync:(NSArray*)properties withAsyncBlock:(DBQueryAsyncResponse)_responseBlock onMainThread:(BOOL)onMainThread;
/**
 * Performs the query as an async operation and returns a handler object. The results are then passed into the supplied DBQueryAsyncResponse block.
 * @author Adrian Herridge
 *
 * @return (DBQueryAsyncHandler*) an async query handler to allow the cancellation of the fetch request.
 */
- (NSArray*)ids;
/**
 * Performs the query and returns the results all within the same DBContext, you will always get an object back even if there are no results.
 * @author Adrian Herridge
 *
 * @return (DBResultSet*) results of the query.  Always returns an object and never returns nil.
 */
- (DBResultSet*)fetchWithContext;
/**
 * Performs the query and returns the results all within the DBContext specified in the context parameter, you will always get an object back even if there are no results.
 * @author Adrian Herridge
 * @param (DBContext*)context specifies the context that all the results should be added to.
 * @return (DBResultSet*) results of the query.  Always returns an object and never returns nil.
 */
- (DBResultSet*)fetchIntoContext:(DBContext*)context;
/**
 * Performs the query and returns the results grouped by the specified property, you will always get an object back even if there are no results.
 * @author Adrian Herridge
 * @param (NSString*)propertyName the property name to group by
 * @return (NSDictionary*) results of the query, the key values are the distinct values of the paramater that was specified.
 */
- (NSDictionary*)groupBy:(NSString*)propertyName;
/**
 * Performs the query and returns the count of the rows within the results.
 * @author Adrian Herridge
 *
 * @return (int)count .
 */
- (int)count;
/**
 * Performs the query and returns the sum of the numeric property that is specified in the parameter.
 * @author Adrian Herridge
 * @param (NSString*)propertyName the property name to perform the SUM aggregation function on.
 * @return (double)  sum of the specified parameter across all results.
 */
- (double)sumOf:(NSString*)propertyName;

@end


/* Fuzzy Store */
/**
 * DBFuzzyStore is a high performance key/value store with tagging, grouping and revisions.
 * @author Adrian Herridge
 */
@interface DBFuzzyStore : NSObject
/// Enable revisioning of stored objects
@property BOOL  enableRevisions;
/// The maximum number of revisions to store against a key
@property int   maxRevisionsPerObject;
/**
 * Adds an object to the store with a reference.
 * @author Adrian Herridge
 *
 * @param (id)object the object to store
 * @param (NSString*)identifier the reference identifier used to reference the object
 * @return void
 */
- (void)addObject:(id)object withIdentifier:(NSString*)identifier;
/**
 * Adds an object to the store with a reference and an array of tags with which to query for items.
 * @author Adrian Herridge
 *
 * @param (id)object the object to store
 * @param (NSString*)identifier the reference identifier used to reference the object
 * @param (NSArray*)tags tags to categorize the stored object
 * @return void
 */
- (void)addObject:(id)object withIdentifier:(NSString*)identifier andTags:(NSArray*)tags;
/**
 * Removes an object from the store with a matching reference.
 * @author Adrian Herridge
 *
 * @param (NSString*)identifier the reference identifier used to reference the object
 * @return void
 */
- (void)removeObjectWithIdentifier:(NSString*)identifier;
/**
 * Retrieves an object from the store with a matching reference.
 * @author Adrian Herridge
 *
 * @param (NSString*)identifier the reference identifier used to reference the object
 * @return id the original object that was given to the store
 */
- (id)objectWithIdentifier:(NSString*)identifier;
/**
 * Retrieves objects from the store with a matching tags.
 * @author Adrian Herridge
 *
 * @param (NSArray*)tags the tags that will be used to match against objects
 * @return (NSArray*) all matches
 */
- (NSArray*)objectsWithTags:(NSArray*)tags;
/**
 * Retrieves all objects from the store.
 * @author Adrian Herridge
 *
 * @return (NSArray*)
 */
- (NSArray*)allStoredObjects;

// revision methods
/**
 * Retrieves an object from the store with a matching reference at a specific revision.
 * @author Adrian Herridge
 *
 * @param (NSString*)identifier the reference identifier used to reference the object
 * @param (int)revision the revision at which to retrieve a stored object
 * @return id the original object that was given to the store
 */
- (id)objectWithIdentifier:(NSString*)identifier atRevision:(int)revision;
/**
 * Retrieves all revisions for a specific object from the store.
 * @author Adrian Herridge
 * @param (NSString*)identifier identifier to retireve revisions for
 * @return (NSArray*) array of revisions
 */
- (NSArray*)revisionsOfObjectWithIdentifier:(NSString*)identifier;

// info methods
/**
 * Retrieves information about an object from the store with a matching reference.
 * @author Adrian Herridge
 *
 * @param (NSString*)identifier the reference identifier used to reference the object
 * @return (NSDictionary*) information held about a specific object
 */
- (NSDictionary*)infoForObjectWithIdentifier:(NSString*)identifier;

@end


















