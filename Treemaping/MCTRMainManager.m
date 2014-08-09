//
//  MCTRMainManager.m
//  Treemap
//
//  Created by Malgorzata Lewandowska on 13/03/14.
//

#import "MCTRMainManager.h"
#import "MCTRCompanyObject.h"
#import "MCTRDataStructure.h"

@interface MCTRMainManager()
@property (atomic) CGFloat val;
@end

@implementation MCTRMainManager

__weak MCTRMainManager *mainManager;

+ (MCTRMainManager*) lastMainManager{
    return mainManager;
}

- (instancetype) init {
    self = [super init];
    if (!self) return nil;
    mainManager = self;
    return self;
}

- (M13OrderedDictionary*) recountTestDataForDirection:(BOOL)isVertical andDict:(M13MutableOrderedDictionary*)dict andArea:(CGRect)area{
    self.val = 0;
    [self valueOfDict:dict];
    CGFloat scale;
    if (isVertical)
        scale = area.size.height/self.val;
    else
        scale = area.size.width/self.val;
    
    M13MutableOrderedDictionary *scaledDict = [dict mutableCopy];
    [self scaleAllValues:scaledDict withScale:scale];
    return scaledDict;
}

- (void) valueOfDict:(M13MutableOrderedDictionary*)dict{
    NSArray *allVal = [dict allObjects];
    for (id object in allVal){
        if ([object isKindOfClass:[NSNumber class]])
        {
            NSNumber *valNum = object;
            CGFloat objVal = [valNum floatValue];
            [self updateValue:objVal];
        }
        else if ([object isKindOfClass:[M13MutableOrderedDictionary class]]) {
            [self valueOfDict:object];
        }
    }
}

- (void) scaleAllValues:(M13MutableOrderedDictionary*)dict withScale:(CGFloat)scale{
    [dict enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        NSString *ID = (NSString*)[dict keyAtIndex:idx];
        if ([object isKindOfClass:[NSNumber class]])
        {
            NSNumber *valNum = object;
            CGFloat objVal = [valNum floatValue];
            objVal = objVal*scale;
            [dict setObject:[NSNumber numberWithFloat:objVal] forKey:ID];
        }
        else if ([object isKindOfClass:[M13MutableOrderedDictionary class]]) {
            [self scaleAllValues:object withScale:scale];
        }
    }];
}

- (void) updateValue:(CGFloat)value {
    self.val += value;
}

- (M13OrderedDictionary*)generateDataWithHierarchy:(NSInteger)deepOfHierarchy {
    M13OrderedDictionary *dict;
    switch (deepOfHierarchy) {
        case 1:
        {
            M13MutableOrderedDictionary * dictio = [[M13MutableOrderedDictionary alloc] init];
            for (int i=1; i<=10; i++) {
                CGFloat value  = [self normalDistributionValue];//exp(drand48()-0.5);
                [dictio setObject:[NSNumber numberWithFloat:value]
                         forKey:[@"dicitio" stringByAppendingString:[NSString stringWithFormat:@"%i",i]]];
            }
            dict = dictio;
        }
            break;
        case 2:
        {
            M13MutableOrderedDictionary *dictio = [[M13MutableOrderedDictionary alloc] init];
            for (int i=1; i<=10; i++) {
                M13MutableOrderedDictionary *dictio2Deep = [[M13MutableOrderedDictionary alloc] init];
                for (int j=1; j<=10; j++) {
                    
                    CGFloat value  = [self normalDistributionValue];//exp(drand48()-0.5);
                    [dictio2Deep setObject:[NSNumber numberWithFloat:value]
                                    forKey:[[@"Lev2e" stringByAppendingString:[NSString stringWithFormat:@"%i",j]]
                                                                               stringByAppendingString:[NSString stringWithFormat:@"%i",i]]];
                }
                [dictio setObject:dictio2Deep forKey:[@"Lev1e" stringByAppendingString:[NSString stringWithFormat:@"%i",i]]];
            }
            dict = dictio;
        }
            break;
        case 3:
        {
            M13MutableOrderedDictionary *dictio = [[M13MutableOrderedDictionary alloc] init];
            for (int i=1; i<=8; i++) {
                M13MutableOrderedDictionary *dictio2Deep = [[M13MutableOrderedDictionary alloc] init];
                for (int j=1; j<=8; j++) {
                    M13MutableOrderedDictionary *dictio3Deep = [[M13MutableOrderedDictionary alloc] init];
                    for (int k=1; k<=8; k++) {
                        CGFloat value  = [self normalDistributionValue];//exp(drand48()-0.5);
                        [dictio3Deep setObject:[NSNumber numberWithFloat:value]
                                        forKey:[[[@"Lev3e" stringByAppendingString:[NSString stringWithFormat:@"%i",i]]
                                                 stringByAppendingString:[NSString stringWithFormat:@"%i",j]]
                                                stringByAppendingString:[NSString stringWithFormat:@"%i",k]]];
                    }
                    [dictio2Deep setObject:dictio3Deep forKey:[@"Lev2e" stringByAppendingString:[NSString stringWithFormat:@"%i",j]]];
                }
                [dictio setObject:dictio2Deep forKey:[@"Lev1e" stringByAppendingString:[NSString stringWithFormat:@"%i",i]]];
            }
            dict = dictio;
        }
            break;

        default:
            break;
    }
    return dict;
}

- (M13OrderedDictionary*) changeData:(M13OrderedDictionary*)dataToChange{
    M13MutableOrderedDictionary *dict = [[M13MutableOrderedDictionary alloc] init];
    [self changeDataInDict:dataToChange saveIn:dict];
    return [[M13OrderedDictionary alloc]initWithOrderedDictionary:dict];
}

- (void) changeDataInDict:(id)object saveIn:(M13MutableOrderedDictionary*)dict{
    M13MutableOrderedDictionary *objectDict = object;
    for (NSString *key in objectDict.allKeys){
        id obj = [objectDict objectForKey:key];
        if ([obj isKindOfClass:[NSNumber class]])
        {
            CGFloat value  = [self normalDistributionValue];//exp(drand48()-0.5);
            [dict setObject:[NSNumber numberWithFloat:value] forKey:key];
        }
        else
        {
            M13MutableOrderedDictionary *newDict = [[M13MutableOrderedDictionary alloc] init];
            [dict setObject:newDict forKey:key];
            [self changeDataInDict:obj saveIn:newDict];
        }
    }
    
}

- (CGFloat) recountChangeBetween:(M13OrderedDictionary*)firstDict andDict:(M13OrderedDictionary*)secondDict {
    CGFloat change  = 0;
    for (NSString *key in firstDict) {
        CGRect firstRect = [[firstDict objectForKey:key] rectValue];
        CGRect secondRect = [[secondDict objectForKey:key] rectValue];
        CGFloat distance = sqrtf(powf(firstRect.origin.x-secondRect.origin.x,2)+powf(firstRect.origin.y-secondRect.origin.y,2));
        change += distance;
    }
    change = change/firstDict.count;
    return change;
    
}

- (CGFloat) normalDistributionValue {
    double u1 = (double)arc4random() / UINT32_MAX; // uniform distribution
    double u2 = (double)arc4random() / UINT32_MAX; // uniform distribution
    double f1 = sqrt(-2 * log(u1));
    double f2 = 2 * M_PI * u2;
    double g1 = f1 * cos(f2); // gaussian distribution
    double g2 = f1 * sin(f2); // gaussian distribution
    g1 = (CGFloat)g1;
    if (g1<0) g1 = g1*(-1);
    g1 = exp(g1-0.5);
    
    return g1;
}

@end