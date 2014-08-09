//
//  MCTRCompanyObject.h
//  Treemap
//
//  Created by Malgorzata Lewandowska on 15/03/14.
//

@interface MCTRCompanyObject : NSObject

@property (strong, nonatomic) NSString * companyID;
@property (assign, nonatomic) CGFloat openValue;
@property (assign, nonatomic) CGFloat highValue;
@property (assign, nonatomic) CGFloat lowValue;
@property (assign, nonatomic) CGFloat actualValue;
@property (assign, nonatomic) NSInteger volume;
@property (assign, nonatomic) NSInteger openInteset;

- (instancetype) initWithNSString:(NSString*) stringWithData;

@end
