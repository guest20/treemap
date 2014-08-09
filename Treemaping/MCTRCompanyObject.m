//
//  MCTRCompanyObject.m
//  Treemap
//
//  Created by Malgorzata Lewandowska on 15/03/14.
//

#import "MCTRCompanyObject.h"

@implementation MCTRCompanyObject

- (instancetype) initWithNSString:(NSString*) stringWithData {
    self = [super init];
    
    if (!self) return nil;
    
    NSArray * splitedData = [stringWithData componentsSeparatedByString:@","];
    
    //format floats to two digits
    
    self.companyID = [splitedData objectAtIndex:0];
    self.openValue =  [[splitedData objectAtIndex:2] floatValue];
    self.highValue = [[splitedData objectAtIndex:3] floatValue];
    self.lowValue  = [[splitedData objectAtIndex:4] floatValue];
    self.actualValue = [[splitedData objectAtIndex:5] floatValue];
    self.volume = [[splitedData objectAtIndex:6] intValue];
    self.openInteset = [[splitedData objectAtIndex:7] intValue];
    
    return self;
}

@end
