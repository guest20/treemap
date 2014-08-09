//
//  MCTRTreemapView.h
//  Treemap
//
//  Created by Malgorzata Lewandowska on 06/06/14.
//

@protocol MCTRTreemapViewDelegate
-(void) drawBackground;
@end


@interface MCTRTreemapView : NSView

@property (weak,nonatomic) id <MCTRTreemapViewDelegate> delegate;

@property (strong,nonatomic) M13MutableOrderedDictionary*dictWitValues;
@property (strong,nonatomic) M13MutableOrderedDictionary*dictWitRects;
@property (strong,nonatomic) M13OrderedDictionary *oldVals;
- (instancetype) initWithFrame:(CGRect)frame andData:(M13OrderedDictionary*)rectsArray;
- (NSInteger) deepOfHierarchy:(M13MutableOrderedDictionary*)dict;
- (void) setColor:(NSInteger)level;
- (void) setLabelFont:(NSInteger)level inLabel:(NSTextField*)label;
- (CGFloat) recountAreaForDict:(M13MutableOrderedDictionary*)dict value:(CGFloat)value;

- (CGFloat) averageAspectRatio:(M13MutableOrderedDictionary*)dictWitRects;
- (CGFloat)aspectRatioOfRect:(CGRect)rect;

@end
