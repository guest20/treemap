//
//  MCTRDataStructure.h
//  Treemap
//
//  Created by Malgorzata Lewandowska on 31/05/14.
//

#import <Foundation/Foundation.h>

@interface MCTRDataStructure : NSObject

+ (id)sharedData;

@property (nonatomic,strong) M13OrderedDictionary *dataDictionary;

-(M13OrderedDictionary*) parseOneDimDataFromFileAtPath:(NSString*)filePath;

-(M13OrderedDictionary*)trafficFlowData;
-(M13OrderedDictionary*)wineQualityData;
-(M13OrderedDictionary*)airPollutionData;
-(M13OrderedDictionary*)customData:(NSString*)filePath;
@end
