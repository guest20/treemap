//
//  MCTRMainManager.h
//  Treemap
//
//  Created by Malgorzata Lewandowska on 13/03/14.
//

@protocol MCTRMainManagerProtocol <NSObject>

- (void) update;

@end

@interface MCTRMainManager : NSObject
+ (MCTRMainManager*) lastMainManager;

@property (nonatomic,strong) M13OrderedDictionary *dict;

- (M13OrderedDictionary*) recountTestDataForDirection:(BOOL)isVertical andDict:(M13MutableOrderedDictionary*)dict andArea:(CGRect)area;
- (M13OrderedDictionary*) generateDataWithHierarchy:(NSInteger)deepOfHierarchy;
- (M13OrderedDictionary*) changeData:(M13OrderedDictionary*)dataToChange;
- (CGFloat) recountChangeBetween:(M13OrderedDictionary*)firstDict andDict:(M13OrderedDictionary*)secondDict;
@end
