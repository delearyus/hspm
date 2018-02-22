{-# LANGUAGE GeneralizedNewtypeDeriving, OverloadedStrings #-}

module Core (PM, runPM, PMConfig, PMState,
       returnROM, initialState, initialConfig,
       ask, modify, get, out, run, edit) where

import Control.Monad.Reader
import Control.Monad.State
import Control.Monad.Writer
import Control.Concurrent
import Data.ByteString as B
import Data.ByteString.Char8 as BC
import Text.Editor

import Types

newtype PMAction a = PMAction { runPMAction :: IO a }
              deriving (Functor, Applicative, Monad, MonadIO)
pmout :: B.ByteString -> PMAction ()
pmout str = PMAction { runPMAction = BC.putStrLn str }

pmrun :: FilePath -> B.ByteString -> PMAction ()
pmrun pipePath cmd = PMAction $ (forkIO $ B.writeFile pipePath cmd) >> return ()

pmedit :: ByteString -> PMAction ByteString
pmedit f = PMAction { runPMAction = runUserEditorDWIM (mkTemplate "txt") f }

liftPMA = lift . lift

newtype PM a = PM { getPm :: ReaderT PMConfig (StateT PMState PMAction) a }
              deriving (Functor, Applicative, Monad,
                        MonadReader PMConfig, MonadState PMState, MonadIO)
-- first writer is output, second writer is cmd


runPM :: PMConfig -> PMState -> (PM a) -> IO (a, PMState)
runPM conf state p = runPMAction $ runStateT (runReaderT (getPm p) conf) state

out :: B.ByteString -> PM ()
out str = PM $ liftPMA (pmout str)

run :: B.ByteString -> PM ()
run str = PM $ do
            pp <- fmap _pipeDir ask
            liftPMA (pmrun pp str)

edit :: B.ByteString -> PM B.ByteString
edit str = PM $ liftPMA (pmedit str)



type PMState = ProjectList

returnROM :: PM (Either String String)
returnROM = PM $ do
              conf <- ask
              modify transformation
              return $ Left "cd /home/jamie/Documents/Personal/Haskell"

initialState = defaultProjectList
initialConfig = PMConfig {  _command = List
                          , _pipeDir = "/home/jamie/.hspm/pipe"
                          , _projDir = "/home/jamie/.hspm/projects"
                         }

transformation :: ProjectList -> ProjectList
transformation (Projects Nothing ps) = (Projects (Just 1) ps)
transformation (Projects (Just n) ps) = (Projects (Just $ succ n) ps)
