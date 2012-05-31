//
//  HMRStore.h
//  HMRStore
//
//  Created by Tiago Bastos on 30/05/2012.
//  Copyright (c) 2012 Guilda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface HMRStore : NSObject {
    sqlite3 *databaseHandle;
}

@property (nonatomic, assign) sqlite3 *databaseHandle;
@property (nonatomic, copy) NSString *databasePath;

+ (HMRStore*)sharedInstance;
+ (HMRStore*)sharedInstanceWithDatabasePath:(NSString*)databasePath;

- (void)setupDatabase;
- (void)value:(id)value forKey:(NSString *)key error:(NSError**)error;
- (id)valueForKey:(NSString *)key error:(NSError**)error;
- (void)deleteValueForKey:(NSString *)key error:(NSError**)error;

@end
