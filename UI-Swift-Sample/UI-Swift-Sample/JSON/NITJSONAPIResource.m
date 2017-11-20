//
//  NITJSONAPIResource.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITJSONAPIResource.h"

#define IDKey @"ID"
#define TypeKey @"type"
#define AttributesKey @"attributes"
#define RelationshipsKey @"relationships"

@interface NITJSONAPIResource()

@property (nonatomic, strong) NSMutableDictionary<NSString*, id> *attributes;
@property (nonatomic, strong) NSMutableDictionary<NSString*, id> *relationships;

@end

@implementation NITJSONAPIResource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.attributes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.ID = [aDecoder decodeObjectForKey:IDKey];
        self.type = [aDecoder decodeObjectForKey:TypeKey];
        self.attributes = [aDecoder decodeObjectForKey:AttributesKey];
        self.relationships = [aDecoder decodeObjectForKey:RelationshipsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:IDKey];
    [aCoder encodeObject:self.type forKey:TypeKey];
    [aCoder encodeObject:self.attributes forKey:AttributesKey];
    [aCoder encodeObject:self.relationships forKey:RelationshipsKey];
}

- (void)addAttributeObject:(id)object forKey:(NSString*)key {
    [_attributes setObject:object forKey:key];
}

- (NSInteger)attributesCount {
    return [self.attributes count];
}

- (NSDictionary<NSString *,id> *)attributes {
    return _attributes;
}

- (id)attributeForKey:(NSString *)key {
    return [self.attributes objectForKey:key];
}

- (NSDictionary<NSString *,id> *)relationships {
    return _relationships;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary<NSString*, id> *dict = [[NSMutableDictionary alloc] init];
    
    if (self.ID) {
        [dict setObject:self.ID forKey:@"id"];
    }
    [dict setObject:self.type forKey:@"type"];
    
    if ([self.attributes count] > 0) {
        [dict setObject:self.attributes forKey:@"attributes"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary*)relationshipForKey:(NSString*)key {
    return [self.relationships objectForKey:key];
}

+ (NITJSONAPIResource *)resourceObjectWithDictiornary:(NSDictionary *)dictionary {
    NITJSONAPIResource *resourceObject = [[NITJSONAPIResource alloc] init];
    
    resourceObject.ID = [dictionary objectForKey:@"id"];
    resourceObject.type = [dictionary objectForKey:@"type"];
    NSDictionary<NSString*, id> *attributes = [dictionary objectForKey:@"attributes"];
    if (attributes) {
        resourceObject.attributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    }
    NSDictionary<NSString*, id> *relationships = [dictionary objectForKey:@"relationships"];
    if (relationships) {
        resourceObject.relationships = [[NSMutableDictionary alloc] initWithDictionary:relationships];
    }
    
    return resourceObject;
}

@end
