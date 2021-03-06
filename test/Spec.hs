module Main where

import Control.Comonad
import Life
import Life.Examples
import Test.Hspec

-- | Sample size
sSize :: Int
sSize = 20

-- | Board size (each side)
bSize :: Int
bSize = 20

main :: IO ()
main = hspec $ do

  describe "Still lifes" $ do
    it "blocks are still" $
      testStill block
    it "beehives are still" $
      testStill beehive
    it "tubs are still" $
      testStill tub

  describe "Oscillators" $ do
    it "blinkers oscillate with period 2" $
      testOscillate 2 blinker
    it "toads oscillate with period 2" $
      testOscillate 2 toad
    it "beacons oscillate with period 2" $
      testOscillate 2 beacon
    it "pentadecathlons oscillate with period 15" $
      testOscillate 15 pentadecathlon

  describe "Spaceships" $
    it "gliders result in constant population" $
      let ps = map population $ game $ glider bSize bSize
       in take sSize ps `shouldBe` replicate sSize 5

  describe "Zipper comonad implementation" $ do
    let g  = glider 5 5
        sg = shift N $ shift W $ g
    it "passes first law" $ do
      testFirstLaw g
      testFirstLaw sg
    it "passes second law" $ do
      testSecondLaw g
      testSecondLaw sg
    it "passes third law" $ do
      testThirdLaw g
      testThirdLaw sg

testFirstLaw :: Board -> Expectation
testFirstLaw = shouldBe
  <$> extract . duplicate
  <*> id

testSecondLaw :: Board -> Expectation
testSecondLaw = shouldBe
  <$> fmap extract . duplicate
  <*> id

testThirdLaw :: Board -> Expectation
testThirdLaw = shouldBe
  <$> duplicate . duplicate
  <*> fmap duplicate . duplicate

testStill :: (Int -> Int -> Board) -> Expectation
testStill b = testStillB $ b bSize bSize

testOscillate :: Int -> (Int -> Int -> Board) -> Expectation
testOscillate p b = testOscillateB p $ b bSize bSize

testStillB :: Board -> Expectation
testStillB b =
   take sSize (game b) `shouldBe` replicate sSize b

testOscillateB :: Int -> Board -> Expectation
testOscillateB p b =
  take (sSize * p) (game b) `shouldBe` (take (sSize * p) . cycle . take p $ game b)

game :: Board -- ^ Initial board
     -> [Board] -- ^ Resulting game
game = iterate step
