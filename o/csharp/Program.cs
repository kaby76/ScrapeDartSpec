namespace csharp
{
    using Antlr4.Runtime;
    using System;

    public class Program
    {
	    static bool display_tokens = false;
	    static bool display_tree = false;
	    
        static void Main(string[] args)
        {
            for (int i = 0; i < args.Length; ++i)
            {
                if (args[i].StartsWith("-tree"))
                    display_tree = true;
                else if (args[i].StartsWith("-tokens"))
                    display_tokens = true;
                else
                {
                    var fn = args[i];
                    var input = System.IO.File.ReadAllText(fn);
                    Try(input);
                }
            }
        }

        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            var lexer = new DartLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new DartParser(tokens);
            var listener_lexer = new ErrorListener<int>();
            var listener_parser = new ErrorListener<IToken>();
            lexer.AddErrorListener(listener_lexer);
            parser.AddErrorListener(listener_parser);
            var tree = parser.libraryDefinition();
            if (display_tokens)
            {
                foreach (var t in tokens.GetTokens())
                {
                    System.Console.WriteLine(t.ToString());
                }
            }
            if (display_tree)
            {
                System.Console.WriteLine(TreeOutput.OutputTree(tree, lexer, tokens).ToString());
            }
            if (listener_lexer.had_error || listener_parser.had_error)
            {
                System.Console.WriteLine("error in parse.");
                throw new Exception();
            }
            else
                System.Console.WriteLine("parse completed.");
        }
    }
}
