module Main where

import System.Environment
import System.Directory
import System.Process
import System.Posix.Files
import Control.Exception
import Control.Monad
import Control.Concurrent
{-import System.Process-}

import qualified Data.ByteString.Lazy as B
import Data.Binary.Get as G
import Data.Binary.Put as P
import Data.Binary as BI

import Core
import Actions

main :: IO ()
main = runHSPM dispatch

{- This part will probably be gotten from ENV eventually -}

pipePath = "/home/jamie/.hspm/pipe"
persPath = "/home/jamie/.hspm/projects"
persPathTemp = "/home/jamie/.hspm/temp"

{- (end) -}

runHSPM :: PM () -> IO ()
runHSPM pm = do

  -- check if our pipe exist. Unfortunately doesn't check if its actually
  -- a pipe, but oh well.
  fileExists <- doesFileExist pipePath
  when (not fileExists) $ createNamedPipe pipePath ownerModes

  {-args <- getArgs-}
  let args = initialConfig
  state <- G.runGet (BI.get :: Get PMState) <$> B.readFile persPath

  return ()
  ((), newstate) <- runPM args state pm

  print newstate

  threadDelay 100000 --0.1s
