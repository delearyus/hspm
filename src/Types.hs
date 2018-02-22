{-# LANGUAGE DeriveGeneric, OverloadedStrings, TemplateHaskell #-}

module Types where

import Data.Binary
import GHC.Generics (Generic)
import Data.ByteString
import Control.Lens

data Verb
  = List
  | Start Project
  | Stop
  | Info Project
  | Edit Editable Project
  | Create Project
  | Delete Project
  | Help
  | Version
  deriving (Eq, Show, Read)

data Editable = EditName | EditDesc | EditStart | EditStop
  deriving (Eq, Ord, Bounded, Enum, Show, Read)

data Project = Project {
  _pid :: Int,
  _name  :: ByteString,
  _blurb :: ByteString,
  _desc  :: ByteString,
  _startCmd :: ByteString,
  _stopCmd  :: ByteString
} deriving (Eq, Read, Show, Generic)
makeLenses ''Project

data ProjectList = Projects {
    _current :: Maybe Int,
    _projects :: [Project]
    } deriving (Show, Generic)
makeLenses ''ProjectList

data PMConfig = PMConfig {
                      _command :: Verb
                    , _pipeDir :: FilePath
                    , _projDir :: FilePath
                   }
makeLenses ''PMConfig

lookupProject :: ProjectList -> Int -> Maybe Project
lookupProject (Projects _ ps) n = lookup' n ps
  where lookup' n [] = Nothing
        lookup' n (p:ps) = if p^.pid == n then Just p else lookup' n ps

getCurrentProject p = p^.current >>= lookupProject p

instance Binary Project
instance Binary ProjectList

defaultProject :: Project
defaultProject = Project {
  _pid = 0,
  _name = "A Poisoned Peace",
  _blurb = "A Murder Mystery",
  _desc = "Written by Jamie Leary and Wren Andrus, first run is on 2/17",
  _startCmd = "cd ~/Documents/Personal/murdermystery",
  _stopCmd = "cd ~"
}

defaultProjectList = Projects Nothing [defaultProject]
