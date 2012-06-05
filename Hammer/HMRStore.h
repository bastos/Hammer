//
//  HMRStore.h
//  HMRStore
//
//  Created by Tiago Bastos on 30/05/2012.
//  Copyright (c) 2012 GUILDA TECNOLOGIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

extern NSInteger const HMRStoreKVType;
extern NSInteger const HMRStoreListType;


@interface HMRStore : NSObject {
    sqlite3 *databaseHandle;
}

@property (nonatomic, assign) sqlite3 *databaseHandle;
@property (nonatomic, copy) NSString *databasePath;

+ (HMRStore*)sharedInstance;
+ (HMRStore*)sharedInstanceWithDatabasePath:(NSString*)databasePath;

- (void)setupDatabase;

- (void)getValue:(id)value forKey:(NSString *)key error:(NSError**)error;
- (id)valueForKey:(NSString *)key error:(NSError**)error;
- (void)removeValueForKey:(NSString *)key error:(NSError**)error;

- (void)pushValue:(id)value toList:(NSString *)key error:(NSError**)error;
- (id)popValueFromList:(NSString *)key error:(NSError**)error;
- (id)shiftValueFromList:(NSString *)key error:(NSError**)error;
- (id)getValuesFromList:(NSString *)key error:(NSError**)error;
- (void)removeListForKey:(NSString *)key error:(NSError**)error;

@end
