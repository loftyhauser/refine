#!/usr/bin/env ruby
#
# $Id$
#
# Mobility test for grid c lib

exit 1 unless system 'ruby makeRubyExtension.rb Grid adj.h gridStruct.h master_header.h'
exit 1 unless system 'ruby makeRubyExtension.rb GridMetric adj.h grid.h gridStruct.h master_header.h'
exit 1 unless system 'ruby makeRubyExtension.rb GridSwap adj.h grid.h gridmetric.h gridStruct.h master_header.h'

require 'test/unit'
require 'Adj/Adj'
require 'Grid/Grid'
require 'GridSwap/GridSwap'
require 'GridMetric/GridMetric'

class Grid
 include GridMetric
 include GridSwap
 def totalVolume
  vol = 0.0
  ncell.times { |cellId| vol += volume(cell(cellId)) }
  vol
 end
end

class TestGridSwap < Test::Unit::TestCase

 def faceSwapGrid(dz=0.1)
  grid = Grid.new(10,10,10,10)
  grid.addNode(0,0,0)
  grid.addNode(1,0,0)
  grid.addNode(0,1,0)
  grid.addNode(0.3,0.3,dz)
  grid.addNode(0.3,0.3,-dz)
  grid.addCell(0,1,2,3)
  grid.addCell(0,2,1,4)
  grid  
 end

 def testFaceSwap
  grid = faceSwapGrid
  assert_equal    2, grid.ncell
  assert_nil         grid.swapFace(1,2,3)
  assert_nil         grid.swapFace(1,3,4)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_equal    2, grid.ncell
  assert_equal grid, grid.swapFace(0,1,2)
  assert_equal    3, grid.ncell
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
 end

 def testFaceSwapNotBetter
  grid = faceSwapGrid(1.0)
  assert_nil      grid.swapFace(0,1,2)
  assert_equal 2, grid.ncell
 end

 def testSwapCallsEdgeSwap
  grid = faceSwapGrid
  assert_equal grid, grid.swap
  assert_equal    3, grid.ncell
 end

 def testSwapEdgeNotBeter
  assert_not_nil grid=gemGrid(3, 2.0, 0)
  assert_nil grid.swapEdge(0,1)
  assert_not_nil grid=gemGrid(4, 2.0, 0)
  assert_nil grid.swapEdge(0,1)
  assert_not_nil grid=gemGrid(5, 2.0, 0)
  assert_nil grid.swapEdge(0,1)
  assert_not_nil grid=gemGrid(6, 2.0, 0)
  assert_nil grid.swapEdge(0,1)
  assert_not_nil grid=gemGrid(7, 2.0, 0)
  assert_nil grid.swapEdge(0,1)
  assert_not_nil grid=gemGrid(8, 2.0, 0)
  assert_nil grid.swapEdge(0,1)
  assert_not_nil grid=gemGrid(9, 2.0, 0)
  assert_nil grid.swapEdge(0,1)
 end

 def testSwapEdge3
  assert_not_nil grid=gemGrid(3, 0.1, 0)
  initalVolume = grid.totalVolume

  assert_equal grid, grid.freezeNode(0)
  assert_equal grid, grid.freezeNode(1)
  assert_equal nil,  grid.swapEdge(0,1)
  assert_equal 3, grid.cellDegree(0)
  assert_equal 3, grid.cellDegree(1)
  assert_equal grid, grid.thawNode(1)

  assert_equal grid, grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 1, grid.cellDegree(0)
  assert_equal 1, grid.cellDegree(1)
  assert_equal 2, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 2, grid.cellDegree(4)
 end

 def testSwapEdge4_0
  assert_not_nil grid=gemGrid(4, 0.1, 0)
  initalVolume = grid.totalVolume
  assert_equal grid, grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 2, grid.cellDegree(0)
  assert_equal 2, grid.cellDegree(1)
  assert_equal 4, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 2, grid.cellDegree(5)
 end

 def testSwapEdge4_1
  assert_not_nil grid=gemGrid(4, 0.1, 1)
  initalVolume = grid.totalVolume
  assert_equal grid, grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 2, grid.cellDegree(0)
  assert_equal 2, grid.cellDegree(1)
  assert_equal 2, grid.cellDegree(2)
  assert_equal 4, grid.cellDegree(3)
  assert_equal 2, grid.cellDegree(4)
  assert_equal 4, grid.cellDegree(5)
 end

 def testSwapEdge4_invalid
  assert_not_nil grid=gemGrid(4, 0.1, nil, -0.1)
  grid.swapEdge(0,1)
  assert_equal 4, grid.cellDegree(0)
  assert_equal 4, grid.cellDegree(1)
 end


 def testSwapEdge4_gapWithSameFaces
  assert_not_nil     grid=gemGrid(4, nil, nil, nil, true)
  assert_equal 3,    grid.ncell
  grid.addFaceUV(0,0.0,10.0,
		 1,1.0,11.0,
		 2,2.0,12.0,11)
  grid.addFaceUV(1,1.0,11.0,
		 0,0.0,10.0,
		 5,5.0,15.0,11)
  assert grid.rightHandedBoundary, "original boundary is not right handed"
  assert_equal grid, grid.swapEdge(0,1)
  assert_equal 4,    grid.ncell
  assert_equal 2,    grid.cellDegree(0)
  assert_equal 2,    grid.cellDegree(1)
  # new bc faces
  assert_equal 11,   grid.faceId(0,2,5)
  assert_equal 11,   grid.faceId(1,2,5)  
  assert_nil         grid.faceId(0,1,2)
  assert_nil         grid.faceId(0,1,5) 
  assert grid.rightHandedBoundary, "swapped boundary is not right handed"
  assert_equal [0.0,10.0], grid.nodeUV(0,11)
  assert_equal [1.0,11.0], grid.nodeUV(1,11)
  assert_equal [2.0,12.0], grid.nodeUV(2,11)
  assert_equal [5.0,15.0], grid.nodeUV(5,11)
 end

 def testSwapEdge4_gapWithSameFaceNotBeter
  assert_not_nil     grid=gemGrid(4, 2.0, nil, nil, true)
  assert_equal 3,    grid.ncell
  grid.addFace(0,1,2,11)
  grid.addFace(0,1,5,11)
  assert_nil         grid.swapEdge(0,1)
  assert_equal 3,    grid.ncell
  assert_equal 3,    grid.cellDegree(0)
  assert_equal 3,    grid.cellDegree(1)
  assert_equal 11,   grid.faceId(0,1,2)
  assert_equal 11,   grid.faceId(0,1,5)  
 end

 def testSwapEdge4_gapWithDifferentFaces
  assert_not_nil     grid=gemGrid(4, nil, nil, nil, true)
  assert_equal 3,    grid.ncell
  grid.addFace(0,1,2,2)
  grid.addFace(0,1,5,5)
  assert_nil         grid.swapEdge(0,1)
  assert_equal 3,    grid.ncell
  assert_equal 3,    grid.cellDegree(0)
  assert_equal 3,    grid.cellDegree(1)
  assert_equal 2,    grid.faceId(0,1,2)
  assert_equal 5,    grid.faceId(0,1,5)  
 end

 def testSwapEdge4_gapWithSameAndExistingFace0
  assert_not_nil     grid=gemGrid(4, nil, nil, nil, true)
  assert_equal 3,    grid.ncell
  grid.addFace(0,1,2,11)
  grid.addFace(0,1,5,11)
  grid.addFace(0,2,5,20)
  assert_nil         grid.swapEdge(0,1)
  assert_equal 3,    grid.ncell
  assert_equal 3,    grid.cellDegree(0)
  assert_equal 3,    grid.cellDegree(1)
  assert_equal 11,   grid.faceId(0,1,2)
  assert_equal 11,   grid.faceId(0,1,5)  
 end

 def testSwapEdge4_gapWithSameAndExistingFace1
  assert_not_nil     grid=gemGrid(4, nil, nil, nil, true)
  assert_equal 3,    grid.ncell
  grid.addFace(0,1,2,11)
  grid.addFace(0,1,5,11)
  grid.addFace(1,2,5,20)
  assert_nil         grid.swapEdge(0,1)
  assert_equal 3,    grid.ncell
  assert_equal 3,    grid.cellDegree(0)
  assert_equal 3,    grid.cellDegree(1)
  assert_equal 11,   grid.faceId(0,1,2)
  assert_equal 11,   grid.faceId(0,1,5)  
 end

 def testSwapEdge5_0
  assert_not_nil grid=gemGrid(5, 0.1, 0)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 3, grid.cellDegree(0)
  assert_equal 3, grid.cellDegree(1)
  assert_equal 6, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 4, grid.cellDegree(5)
  assert_equal 2, grid.cellDegree(6)
 end

 def testSwapEdge5_1
  assert_not_nil grid=gemGrid(5, 0.1, 1)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 3, grid.cellDegree(0)
  assert_equal 3, grid.cellDegree(1)
  assert_equal 2, grid.cellDegree(2)
  assert_equal 6, grid.cellDegree(3)
  assert_equal 2, grid.cellDegree(4)
  assert_equal 4, grid.cellDegree(5)
  assert_equal 4, grid.cellDegree(6)
 end

 def testSwapEdge5_2
  assert_not_nil grid=gemGrid(5, 0.1, 2)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 3, grid.cellDegree(0)
  assert_equal 3, grid.cellDegree(1)
  assert_equal 4, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 6, grid.cellDegree(4)
  assert_equal 2, grid.cellDegree(5)
  assert_equal 4, grid.cellDegree(6)
 end

 def testSwapEdge5_3
  assert_not_nil grid=gemGrid(5, 0.1, 3)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 3, grid.cellDegree(0)
  assert_equal 3, grid.cellDegree(1)
  assert_equal 4, grid.cellDegree(2)
  assert_equal 4, grid.cellDegree(3)
  assert_equal 2, grid.cellDegree(4)
  assert_equal 6, grid.cellDegree(5)
  assert_equal 2, grid.cellDegree(6)
 end

 def testSwapEdge5_4
  assert_not_nil grid=gemGrid(5, 0.1, 4)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 3, grid.cellDegree(0)
  assert_equal 3, grid.cellDegree(1)
  assert_equal 2, grid.cellDegree(2)
  assert_equal 4, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 2, grid.cellDegree(5)
  assert_equal 6, grid.cellDegree(6)
 end

 def testSwapEdge5_gapWithSameFaces
  assert_not_nil     grid=gemGrid(5, nil, nil, nil, true)
  assert_equal 4,    grid.ncell
  grid.addFace(0,1,2,11)
  grid.addFace(1,0,6,11)
  assert grid.rightHandedBoundary, "original boundary is not right handed"
  assert_equal grid, grid.swapEdge(0,1)
  assert_equal 6,    grid.ncell
  assert_equal 3,    grid.cellDegree(0)
  assert_equal 3,    grid.cellDegree(1)
  # new bc faces
  assert_equal 11,   grid.faceId(0,2,6)
  assert_equal 11,   grid.faceId(1,2,6)  
  assert_nil         grid.faceId(0,1,2)
  assert_nil         grid.faceId(0,1,6) 
  assert grid.rightHandedBoundary, "swapped boundary is not right handed"
 end

 def testSwapEdge6OnePoint_0
  assert_not_nil grid=gemGrid(6, 0.1, 0)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 4, grid.cellDegree(0)
  assert_equal 4, grid.cellDegree(1)
  assert_equal 8, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 4, grid.cellDegree(5)
  assert_equal 4, grid.cellDegree(6)
  assert_equal 2, grid.cellDegree(7)
 end

 def testSwapEdge6OnePoint_1
  assert_not_nil grid=gemGrid(6, 0.1, 1)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 4, grid.cellDegree(0)
  assert_equal 4, grid.cellDegree(1)
  assert_equal 2, grid.cellDegree(2)
  assert_equal 8, grid.cellDegree(3)
  assert_equal 2, grid.cellDegree(4)
  assert_equal 4, grid.cellDegree(5)
  assert_equal 4, grid.cellDegree(6)
  assert_equal 4, grid.cellDegree(7)
 end

 def testSwapEdge6OnePoint_2
  assert_not_nil grid=gemGrid(6, 0.1, 2)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 4, grid.cellDegree(0)
  assert_equal 4, grid.cellDegree(1)
  assert_equal 4, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 8, grid.cellDegree(4)
  assert_equal 2, grid.cellDegree(5)
  assert_equal 4, grid.cellDegree(6)
  assert_equal 4, grid.cellDegree(7)
 end

 def testSwapEdge6OnePoint_3
  assert_not_nil grid=gemGrid(6, 0.1, 3)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 4, grid.cellDegree(0)
  assert_equal 4, grid.cellDegree(1)
  assert_equal 4, grid.cellDegree(2)
  assert_equal 4, grid.cellDegree(3)
  assert_equal 2, grid.cellDegree(4)
  assert_equal 8, grid.cellDegree(5)
  assert_equal 2, grid.cellDegree(6)
  assert_equal 4, grid.cellDegree(7)
 end

 def testSwapEdge6OnePoint_4
  assert_not_nil grid=gemGrid(6, 0.1, 4)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 4, grid.cellDegree(0)
  assert_equal 4, grid.cellDegree(1)
  assert_equal 4, grid.cellDegree(2)
  assert_equal 4, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 2, grid.cellDegree(5)
  assert_equal 8, grid.cellDegree(6)
  assert_equal 2, grid.cellDegree(7)
 end

 def testSwapEdge6OnePoint_5
  assert_not_nil grid=gemGrid(6, 0.1, 5)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 4, grid.cellDegree(0)
  assert_equal 4, grid.cellDegree(1)
  assert_equal 2, grid.cellDegree(2)
  assert_equal 4, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 4, grid.cellDegree(5)
  assert_equal 2, grid.cellDegree(6)
  assert_equal 8, grid.cellDegree(7)
 end

 def testSwapEdge7OnePoint_0
  assert_not_nil grid=gemGrid(7, 0.1, 0)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal  5, grid.cellDegree(0)
  assert_equal  5, grid.cellDegree(1)
  assert_equal 10, grid.cellDegree(2)
 end

 def testSwapEdge7OnePoint_6
  assert_not_nil grid=gemGrid(7, 0.1, 6)
  initalVolume = grid.totalVolume
  grid.swapEdge(0,1)
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal  5, grid.cellDegree(0)
  assert_equal  5, grid.cellDegree(1)
  assert_equal 10, grid.cellDegree(8)
 end

 def testSwap4
  assert_not_nil grid=gemGrid(4, 0.1, 0)
  initalVolume = grid.totalVolume
  assert_equal grid, grid.swap
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 2, grid.cellDegree(0)
  assert_equal 2, grid.cellDegree(1)
  assert_equal 4, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 2, grid.cellDegree(5)
 end

 def testSwap5
  assert_not_nil grid=gemGrid(5, 0.1, 0)
  initalVolume = grid.totalVolume
  grid.swap
  assert grid.minVolume>0.0, "negative volume cell "+grid.minVolume.to_s
  assert_in_delta initalVolume, grid.totalVolume, 1.0e-15
  assert_equal 3, grid.cellDegree(0)
  assert_equal 3, grid.cellDegree(1)
  assert_equal 6, grid.cellDegree(2)
  assert_equal 2, grid.cellDegree(3)
  assert_equal 4, grid.cellDegree(4)
  assert_equal 4, grid.cellDegree(5)
  assert_equal 2, grid.cellDegree(6)
 end

 def gemGrid(nequ=4, a=nil, dent=nil, x0 = nil, gap = nil)
  a  = a  || 0.1
  x0 = x0 || 1.0
  grid = Grid.new(nequ+2+1,14,14,14)
  n = Array.new
  n.push grid.addNode(  x0,0.0,0.0)
  n.push grid.addNode(-1.0,0.0,0.0)
  nequ.times do |i| 
   angle = 2.0*Math::PI*(i-1)/(nequ)
   s = if (dent==i) then 0.9 else 1.0 end
   n.push grid.addNode(0.0,s*a*Math.sin(angle),s*a*Math.cos(angle)) 
  end
  n.push 2
  ngem = (gap)?(nequ-1):(nequ)
  ngem.times do |i|
   grid.addCell(n[0],n[1],n[i+2],n[i+3])
  end
  grid  
 end

 def testSwapFaceArea
  assert_not_nil grid = Grid.new(6,3,4,0)
  grid.addCell( 
	       grid.addNode(0.0,0.0,0.0), 
	       grid.addNode(1.0,0.0,0.0), 
	       grid.addNode(0.0,1.0,0.0), 
	       grid.addNode(0.0,0.0,1.0) )
  grid.addCell( 1, 0, 3, grid.addNode(0.3,-0.5,0.3) )
  grid.addCell( 0, 2, 3, grid.addNode(-0.5,0.3,0.3) )
  
  assert_nil         grid.swapCellFaceArea(0), "no faces"
  grid.addFace(1,0,3,10)
  assert_nil         grid.swapCellFaceArea(0), "one face"
  grid.addFace(0,1,2,20)
  assert_nil         grid.swapCellFaceArea(0), "two different faces"
  assert_not_nil     grid.removeFace(grid.findFace(0,1,2)), "remove bottom"
  grid.addFace(0,1,2,10)
  assert_nil         grid.swapCellFaceArea(0), "two same faces, min area"
  grid.addFace(2,1,3,10)
  assert_nil         grid.swapCellFaceArea(0), "three same faces"
  assert_not_nil     grid.removeFace(grid.findFace(1,0,3)), "remove x=0 face"
  assert_equal true, grid.rightHandedBoundary, "initial left boundary faces"
  assert_equal grid, grid.swapCellFaceArea(0), "two same faces, good swap"
  assert_equal true, grid.rightHandedBoundary, "swap left boundary faces"
  #assert_nil         grid.faceId( 0, 1, 2 )
  #assert_nil         grid.faceId( 2, 1, 3 )
  #assert_equal 10,   grid.faceId( 1, 0, 3 )
  #assert_equal 10,   grid.faceId( 0, 2, 3 )
  #assert_equal 2, grid.ncell
 end


end
