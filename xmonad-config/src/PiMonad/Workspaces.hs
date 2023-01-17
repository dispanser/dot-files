module PiMonad.Workspaces ( projects
                          , projectFile
                          , toggleSideWorkspace
                          , getSideWorkspace
                          , getMainWorkspace
                          , getWorkspaceName
                          , getOtherWorkspace
                          , shiftToOtherWorkspace )
where

import           XMonad
import           XMonad.Actions.DynamicProjects   (Project (..), currentProject,
                                                   projectDirectory)
import           XMonad.Actions.DynamicWorkspaces (addWorkspace)
import qualified XMonad.StackSet                  as W

import           Control.Monad                    (filterM)
import           Data.List                        (isSuffixOf)
import           System.Directory                 (doesDirectoryExist,
                                                   getHomeDirectory,
                                                   listDirectory)
import           System.FilePath.Posix            ((</>))

projects :: IO [Project]
projects = do
  home      <- getHomeDirectory
  let pr    =  home </> "projects"
  entries   <- filter (not . (`elem` [".done", ".todo", ".hold"])) <$> listDirectory pr
  dirs      <- filterM (doesDirectoryExist . (pr </>)) entries
  return $ tmpProject home : concatMap (projectsForDir pr) dirs

-- | resolve a file relative to the current project directory
projectFile :: FilePath -> X FilePath
projectFile f = ( </> f) . projectDirectory <$> currentProject

tmpProject :: FilePath -> Project
tmpProject home = Project {
  projectName      = "scratch",
  projectDirectory = home </> "tmp",
  projectStartHook = Nothing }

projectsForDir :: FilePath -> WorkspaceId -> [Project]
projectsForDir pr d = [ main, side ]
  where main = Project { projectName = d
    , projectDirectory = pr </> d
    , projectStartHook = Nothing }
        side = main { projectName = d ++ "_side" }

getSideWorkspace :: WorkspaceId -> WorkspaceId
getSideWorkspace ws
  | "_side" `isSuffixOf` ws = ws
  | otherwise             = ws ++ "_side"

getMainWorkspace :: WorkspaceId -> WorkspaceId
getMainWorkspace ws
  | "_side" `isSuffixOf` ws = take (length ws - 5) ws
  | otherwise             = ws

getOtherWorkspace :: WorkspaceId -> WorkspaceId
getOtherWorkspace ws
  | "_side" `isSuffixOf` ws = take (length ws - 5) ws
  | otherwise             = ws ++ "_side"

getWorkspaceName :: Project -> String
getWorkspaceName = getMainWorkspace . projectName

toggleSideWorkspace :: X ()
toggleSideWorkspace = do
  workspace <- gets (W.currentTag . windowset)
  addWorkspace $ getOtherWorkspace workspace

shiftToOtherWorkspace :: X ()
shiftToOtherWorkspace = do
  workspace <- gets (W.currentTag . windowset)
  windows $ W.shift (getOtherWorkspace workspace)
