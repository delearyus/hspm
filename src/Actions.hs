{-# LANGUAGE OverloadedStrings #-}

module Actions where

import Types
import Core
import Control.Lens hiding (List)
import Control.Monad

list :: PM ()
list = do ps <- use projects
          forM_ ps $ \p -> out "got a project"

start = do cur <- use current
           case cur of
              (Just n) -> stop >> start
              Nothing -> do (Start p) <- view  
