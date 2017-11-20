//
//  NITJSONAPI.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

@import NearITSDK;
#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"

@interface NITJSONAPI()

@property (nonatomic) NSDictionary* sourceJson;
@property (nonatomic, strong) NSDictionary *meta;
@property (nonatomic, strong) NSMutableArray<NITJSONAPIResource*> *resources;
@property (nonatomic, strong) NSMutableArray<NITJSONAPIResource*> *included;
@property (nonatomic, strong) NSMutableDictionary<NSString*, Class> *registerdClass;

@end

/// Class for handling JSON API
@implementation NITJSONAPI

/// Use it for an empty json
- (instancetype)init {
    self = [super init];
    if (self) {
        self.resources = [[NSMutableArray alloc] init];
        self.included = [[NSMutableArray alloc] init];
        self.registerdClass = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 * Instanciate an object with an initial dictionary
 * @param path Path to JSON Api file
 * @param anError Pointer to a NSError
 */
- (instancetype)initWithContentsOfFile:(NSString*)path error:(NSError**)anError {
    NSError *fileError;
    NSString *jsonContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&fileError];
    if (fileError) {
        if(anError != NULL) {
            *anError = fileError;
        }
        return nil;
    }
    
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
    if(jsonError) {
        if(anError != NULL) {
            *anError = jsonError;
        }
        return nil;
    }
    
    return [self initWithDictionary:json];
}

/**
 * Instanciate an object with an initial dictionary
 * @param json Your json
 */
- (instancetype)initWithDictionary:(NSDictionary*)json {
    self = [self init];
    self.sourceJson = json;
    
    id meta = [json objectForKey:@"meta"];
    if ([meta isKindOfClass:[NSDictionary class]]) {
        self.meta = meta;
    }
    
    id data = [json objectForKey:@"data"];
    if ([data isKindOfClass:[NSArray class]]) {
        for(NSDictionary *resDict in data) {
            NITJSONAPIResource *res = [NITJSONAPIResource resourceObjectWithDictiornary:resDict];
            [self.resources addObject:res];
        }
    } else {
        NITJSONAPIResource *res = [NITJSONAPIResource resourceObjectWithDictiornary:data];
        [self.resources addObject:res];
    }
    
    NSArray *included = [json objectForKey:@"included"];
    if (included) {
        for(NSDictionary *resDict in included) {
            NITJSONAPIResource *res = [NITJSONAPIResource resourceObjectWithDictiornary:resDict];
            [self.included addObject:res];
        }
    }
    
    return self;
}

/**
 * Set the "data" with one resource object
 * @param resourceObject Resource object created externally
 */
- (void)setDataWithResourceObject:(NITJSONAPIResource *)resourceObject {
    [self.resources removeAllObjects];
    [self.resources addObject:resourceObject];
}

- (void)setDataWithResourcesObject:(NSArray<NITJSONAPIResource*>*)resources {
    self.resources = [resources mutableCopy];
}

- (NITJSONAPIResource *)firstResourceObject {
    if ([self.resources count] > 0) {
        return [self.resources objectAtIndex:0];
    }
    return nil;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self.resources count] == 0) {
        [dict setObject:[NSNull null] forKey:@"data"];
    } else if ([self.resources count] == 1) {
        NITJSONAPIResource *res = [self.resources objectAtIndex:0];
        [dict setObject:[res toDictionary] forKey:@"data"];
    } else {
        NSMutableArray *resArray = [[NSMutableArray alloc] initWithCapacity:[self.resources count]];
        for(NITJSONAPIResource *res in self.resources) {
            [resArray addObject:[res toDictionary]];
        }
        [dict setObject:resArray forKey:@"data"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)description {
    NSDictionary *dict = self.sourceJson;
    if (dict == nil) {
        dict = [self toDictionary];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    if(jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        return @"";
    }
}

- (void)registerClass:(Class)cls forType:(NSString *)type {
    Class hcls = [self.registerdClass objectForKey:type];
    if (hcls == nil) {
        [self.registerdClass setObject:cls forKey:type];
    }
}

- (NSArray*)parseToArrayOfObjects {
    NSMutableArray<NITResource*> *objects = [[NSMutableArray alloc] init];
    NSMutableArray<NITResource*> *includeds = [[NSMutableArray alloc] init];
    
    for (NITJSONAPIResource *res in self.resources) {
        id object = [self objectWithResource:res];
        
        if (object) {
            [objects addObject:object];
        }
    }
    
    for (NITJSONAPIResource *res in self.included) {
        id object = [self objectWithResource:res];
        
        if (object) {
            [includeds addObject:object];
        }
    }
    
    NSMutableArray *mergedResources = [[NSMutableArray alloc] init];
    [mergedResources addObjectsFromArray:objects];
    [mergedResources addObjectsFromArray:includeds];
    
    for(NITResource* res in mergedResources) {
        [self resolveRelationshipsWithResouce:res inCollectionOfResources:mergedResources];
    }
    
    return [[NSArray alloc] initWithArray:objects];
}

- (id)objectWithResource:(NITJSONAPIResource*)resourceObject {
    Class cls = [self.registerdClass objectForKey:resourceObject.type];
    if (cls == nil || ![cls isSubclassOfClass:[NITResource class]]) {
        return nil;
    }
    
    NITResource *item = [[cls alloc] init];
    item.resourceObject = resourceObject;
    NSDictionary *attributesMap = [item attributesMap];
    
    for(NSString *key in resourceObject.attributes) {
        id value = [resourceObject.attributes objectForKey:key];
        @try {
            NSString *attributeKey = [attributesMap objectForKey:key];
            if (attributeKey == nil) {
                attributeKey = key;
            }
            if ([value isEqual:[NSNull null]]) {
                [item setValue:nil forKey:attributeKey];
            } else {
                [item setValue:value forKey:attributeKey];
            }
        }
        @catch (NSException *exception) {
            // Ignore it
        }
    }
    
    return item;
}

- (void)resolveRelationshipsWithResouce:(NITResource*)resource inCollectionOfResources:(NSArray<NITResource*>*)collections {
    for(NSString *key in resource.resourceObject.relationships) {
        NSDictionary *relationship = [resource.resourceObject.relationships objectForKey:key];
        id data = [relationship objectForKey:@"data"];
        if(data == nil || [data isEqual:[NSNull null]]) {
            continue;
        }
        
        NSDictionary *attributesMap = [resource attributesMap];
        NSString *attributeKey = [attributesMap objectForKey:key];
        if (attributeKey == nil) {
            attributeKey = key;
        }
        
        if([data isKindOfClass:[NSDictionary class]]) {
            NSString *resID = [data objectForKey:@"id"];
            NSString *type = [data objectForKey:@"type"];
            
            @try {
                [resource valueForKey:key];
                
                NITResource *foundRes = [self findResourceWithID:resID inCollection:collections];
                if (foundRes) {
                    [resource setValue:foundRes forKey:attributeKey];
                } else {
                    NITJSONAPIResource *resourceObject = [[NITJSONAPIResource alloc] init];
                    resourceObject.ID = resID;
                    resourceObject.type = type;
                    NITResource *basicResource = [[NITResource alloc] init];
                    basicResource.resourceObject = resourceObject;
                    [resource setValue:basicResource forKey:attributeKey];
                }
            }
            @catch (NSException *exception) {
                continue;
            }
        } else if([data isKindOfClass:[NSArray class]]) {
            NSMutableArray *objects = [[NSMutableArray alloc] init];
            
            for(NSDictionary *resourceLinkage in data) {
                NSString *resID = [resourceLinkage objectForKey:@"id"];
                
                NITResource *foundRes = [self findResourceWithID:resID inCollection:collections];
                if (foundRes) {
                    [objects addObject:foundRes];
                }
            }
            
            @try {
                [resource setValue:[[NSArray alloc] initWithArray:objects] forKey:attributeKey];
            }
            @catch (NSException *exception) {
                continue;
            }
        }
        
    }
}

- (NITResource*)findResourceWithID:(NSString*)ID inCollection:(NSArray<NITResource*>*)collections {
    for(NITResource *res in collections) {
        if([ID isEqualToString:res.resourceObject.ID]) {
            return res;
        }
    }
    return nil;
}

- (id)resolveRelationshipsWithRoots:(NSArray*)roots includeds:(NSArray*)includeds {
    
    return nil;
}

- (NSArray<NITJSONAPIResource *> *)allResources {
    NSMutableArray *mergedResources = [[NSMutableArray alloc] init];
    [mergedResources addObjectsFromArray:self.resources];
    [mergedResources addObjectsFromArray:self.included];
    return [NSArray arrayWithArray:mergedResources];
}

- (NSArray<NITJSONAPIResource *> *)rootResources {
    return [NSArray arrayWithArray:self.resources];
}

- (NSData *)dataValue {
    NSDictionary *json = [self toDictionary];
    NSData *jsonDataBody = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    return jsonDataBody;
}

+ (NITJSONAPI *)jsonApiWithAttributes:(NSDictionary<NSString*, id> *)attributes type:(NSString *)type {
    NITJSONAPI *json = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = type;
    for (NSString *key in attributes) {
        id object = [attributes objectForKey:key];
        [resource addAttributeObject:object forKey:key];
    }
    [json setDataWithResourceObject:resource];
    return json;
}

+ (NITJSONAPI *)jsonApiWithArray:(NSArray<NSDictionary<NSString*, id>*>*)resources type:(NSString *)type {
    NSMutableArray *jsonResources = [[NSMutableArray alloc] init];
    NITJSONAPI *json = [[NITJSONAPI alloc] init];
    for (NSDictionary *attributes in resources) {
        NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
        resource.type = type;
        for (NSString *key in attributes) {
            id object = [attributes objectForKey:key];
            [resource addAttributeObject:object forKey:key];
        }
        [jsonResources addObject:resource];
    }
    [json setDataWithResourcesObject:jsonResources];
    return json;
}

- (id)metaForKey:(NSString *)key {
    return [self.meta objectForKey:key];
}

// MARK: - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.sourceJson) {
        [aCoder encodeObject:self.sourceJson forKey:@"SourceJSON"];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    id sourceJson = [aDecoder decodeObjectForKey:@"SourceJSON"];
    if (sourceJson && [sourceJson isKindOfClass:[NSDictionary class]]) {
        return [self initWithDictionary:sourceJson];
    } else {
        return [super init];
    }
}

@end
