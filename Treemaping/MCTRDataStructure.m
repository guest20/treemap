//
//  MCTRDataStructure.m
//  Treemap
//
//  Created by Malgorzata Lewandowska on 31/05/14.
//

#import "MCTRDataStructure.h"

@implementation MCTRDataStructure

+ (id)sharedData {
    static MCTRDataStructure *sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[self alloc] init];
    });
    return sharedData;
}

-(instancetype)init{
    self = [super init];
    if (!self) return nil;
    [self createTestDirectory];
    return self;
}

- (void) createTestDirectory {
    //10 tablic z identyfikatorami
    M13MutableOrderedDictionary *dict1 = [[M13MutableOrderedDictionary alloc] init];
    for (int i=1; i<=6; i++) {
        M13MutableOrderedDictionary *dict1i = [[M13MutableOrderedDictionary alloc] init];
        for (int j=1; j<=i*3; j++) {
            
            CGFloat value  = exp(drand48()-0.5);
            [dict1i setObject:[NSNumber numberWithFloat:value] forKey:[[@"value" stringByAppendingString:[NSString stringWithFormat:@"%i",j]]
                                            stringByAppendingString:[NSString stringWithFormat:@"%i",i]]];
        }
        [dict1 setObject:dict1i forKey:[@"dicitio" stringByAppendingString:[NSString stringWithFormat:@"%i",i]]];
    }
    self.dataDictionary = dict1;
}


-(M13OrderedDictionary*) parseOneDimDataFromFileAtPath:(NSString*)filePath{
    M13OrderedDictionary *directory;
    
    M13MutableOrderedDictionary *dictioWithFlow = [[M13MutableOrderedDictionary alloc] init];
    NSString *filepath = [[NSBundle mainBundle] pathForResource:filePath ofType:@"csv"];
    NSString *content =  [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    if (!content)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
    }
    NSArray *arrayfarm = [content componentsSeparatedByString:@"\n"];
    for (NSString *item in arrayfarm) {
        if ([arrayfarm indexOfObject:item] > 0)
        {
            NSArray *itemArray = [item componentsSeparatedByString:@","];
            if (itemArray.count == 2){
                NSString *object = [[itemArray objectAtIndex:1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *key = [[itemArray objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (key.length > 0 && object.length > 0){
                    CGFloat val = [object floatValue];
                    if (val){
                        [dictioWithFlow setObject:[NSNumber numberWithFloat:val] forKey:key];
                    }
                }
            }
        }
    }
    directory = [[M13OrderedDictionary alloc] initWithOrderedDictionary:dictioWithFlow];
    return directory;
}

-(M13OrderedDictionary*) parseTwoDimDataFromFileAtPath:(NSString*)filePath{
    M13OrderedDictionary *directory;
    
    M13MutableOrderedDictionary *dictioWithFlow = [[M13MutableOrderedDictionary alloc] init];
    NSString *filepath = [[NSBundle mainBundle] pathForResource:filePath ofType:@"csv"];
    NSString *content =  [NSString stringWithContentsOfFile:filepath  encoding:NSUTF8StringEncoding error:nil];
    if (!content)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
    }
    NSArray *arrayfarm = [content componentsSeparatedByString:@"\n"];
    NSArray *arrayOfTitles;
    for (NSString *item in arrayfarm) {
        if ([arrayfarm indexOfObject:item] == 0)
        {
            arrayOfTitles = [item componentsSeparatedByString:@","];
        }
        else
        {
            NSArray *itemArray = [item componentsSeparatedByString:@","];
            if (itemArray.count == 2){
                NSString *object = [[itemArray objectAtIndex:1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *key = [[itemArray objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (key.length > 0 && object.length > 0){
                    CGFloat val = [object floatValue];
                    if (val){
                        [dictioWithFlow setObject:[NSNumber numberWithFloat:val] forKey:key];
                    }
                }
            }
            else
            {
                M13MutableOrderedDictionary *secondDimDictio = [[M13MutableOrderedDictionary alloc] init];
                NSString *key = [[itemArray objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                for (int i=1; i<itemArray.count; i++) {
                    NSString *object =[[itemArray objectAtIndex:i] stringByTrimmingCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    CGFloat val = [object floatValue];
                    NSString *secondKey = [arrayOfTitles objectAtIndex:i];
                    [secondDimDictio setObject:[NSNumber numberWithFloat:val] forKey:secondKey];
                }
                [dictioWithFlow setObject:secondDimDictio forKey:key];
            }
        }
    }
    directory = [[M13OrderedDictionary alloc] initWithOrderedDictionary:dictioWithFlow];
    return directory;
}

-(M13OrderedDictionary*)trafficFlowData{
    M13OrderedDictionary *trafficFlowData;
    trafficFlowData = [self parseOneDimDataFromFileAtPath:@"trafficflow"];
    return trafficFlowData;
}

-(M13OrderedDictionary*)wineQualityData{
    M13OrderedDictionary *wineQualityData;
    wineQualityData = [self parseTwoDimDataFromFileAtPath:@"winequality"];
    return wineQualityData;
}

-(M13OrderedDictionary*)airPollutionData{
    M13OrderedDictionary *pollutionData;
    pollutionData = [self parseTwoDimDataFromFileAtPath:@"airpollution"];
    return pollutionData;
}

-(M13OrderedDictionary*)customData:(NSString*)filePath{
    M13OrderedDictionary *pollutionData;
    pollutionData = [self parseTwoDimDataFromFileAtPath:filePath];
    return pollutionData;
}

@end
