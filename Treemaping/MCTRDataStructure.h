//
//  MCTRDataStructure.h
//  Treemap
//
//  Created by Malgorzata Lewandowska on 31/05/14.
//  Copyright (c) 2014 morriscooke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCTRDataStructure : NSObject

+ (id)sharedData;

@property (nonatomic,strong) M13OrderedDictionary *dataDictionary;

-(M13OrderedDictionary*) parseOneDimDataFromFileAtPath:(NSString*)filePath;

-(M13OrderedDictionary*)trafficFlowData;
-(M13OrderedDictionary*)boilersWaterLevelData;
-(M13OrderedDictionary*)wineQualityData;
-(M13OrderedDictionary*)airPollutionData;
-(M13OrderedDictionary*)energyGenerationData;
-(M13OrderedDictionary*)presentationData;
@end
