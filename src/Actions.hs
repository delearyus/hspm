{-# LANGUAGE OverloadedStrings #-}

module Actions where

import Types
import Core
import Control.Lens hiding (List)
import Control.Monad

dispatch :: PM ()
dispatch = do v <- view command
              case v of
                List -> list
                Start _ -> start
                Stop -> stop
                _ -> out "Not implemented"
              run "# end" -- make sure that something gets written to the pipe

list :: PM ()
list = do ps <- use projects
          forM_ ps $ \p -> out "got a project"

start = do cur <- use current
           case cur of
              (Just n) -> stop >> start
              Nothing -> do (Start p) <- view command
                            run $ p^.startCmd

stop = do p' <- use (to getCurrentProject)
          case p' of
            Nothing -> out "no currently active project"
            Just p -> run $ p^.stopCmd
