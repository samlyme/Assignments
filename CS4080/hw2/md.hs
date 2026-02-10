import Data.Char (isDigit)
import GHC.Natural (Natural)

data Inline
  = Plain String
  | Italic String
  | Bold String
  | ItalicBold String
  | Code String
  | Link String String
  | ItalicLink String String
  | BoldLink String String
  | ItalicBoldLink String String
  | Image String String
  | LineBreak

instance Show Inline where
  show :: Inline -> String
  show (Plain text) = text
  show (Italic text) = "(*" ++ text ++ "*)"
  show (Bold text) = "(**" ++ text ++ "**)"
  show (ItalicBold text) = "(***" ++ text ++ "***)"
  show (Code text) = "`" ++ text ++ "`"
  show (Link title ref) = "[" ++ title ++ "](" ++ ref ++ ")"
  show (ItalicLink title ref) = "*[" ++ title ++ "](" ++ ref ++ ")*"
  show (BoldLink title ref) = "**[" ++ title ++ "](" ++ ref ++ ")**"
  show (ItalicBoldLink title ref) = "***[" ++ title ++ "](" ++ ref ++ ")***"
  show (Image alt src) = "![" ++ alt ++ "](" ++ src ++ ")"
  show LineBreak = "\n"

renderInlines :: [Inline] -> String
renderInlines = concatMap show

main :: IO ()
main = putStrLn (renderInlines [Plain "Hello ", Bold "World", LineBreak, Code "Done"])