namespace ScrapeDartSpec
{
    using Antlr4.Runtime;
    using Antlr4.Runtime.Misc;
    using Antlr4.Runtime.Tree;
    using System;
    using System.Collections.Generic;
    using System.Text;

    public class Program
    {
        static bool have_files = false;
        static void Main(string[] args)
        {
            have_files = args.Length > 0;
            if (have_files)
            {
                for (int i = 0; i < args.Length; ++i)
                {
                    if (args[i].StartsWith('-')) continue;
                    var fn = args[i];
                    var input = ReadAllInput(fn);
                    Try(input);
                }
            }
            else
            {
                Try("1 + 2 + 3");
                Try("1 2 + 3");
                Try("1 + +");
            }
        }

        static void Try(string input)
        {
            var str = new AntlrInputStream(input);
            //System.Console.WriteLine(input);
            var lexer = new ScrapeDartLexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new ScrapeDartParser(tokens);
            lexer.Mode(ScrapeDartLexer.Search);
            var listener_lexer = new ErrorListener<int>();
            var listener_parser = new ErrorListener<IToken>();
            lexer.AddErrorListener(listener_lexer);
            parser.AddErrorListener(listener_parser);
            var tree = parser.file();
            if (listener_lexer.had_error || listener_parser.had_error)
            {
                System.Console.WriteLine("error in parse.");
                throw new Exception();
            }
            else
                System.Console.WriteLine("parse completed.");
            var walker = new ParseTreeWalker();
            var listener = new Listen();
            walker.Walk(listener, tree);
            var code = listener.sb.ToString();
            System.Console.WriteLine(code);
        }

        static string ReadAllInput(string fn)
        {
            var input = System.IO.File.ReadAllText(fn);
            return input;
        }

        class Listen : ScrapeDartParserBaseListener
        {
            public StringBuilder sb = new StringBuilder();
            bool skip;

            public Listen()
            { }

            public override void EnterLhs([NotNull] ScrapeDartParser.LhsContext context)
            {
                var lhs_sym = context.GetText().TrimStart('<').TrimEnd('>');
                if (lhs_sym == "aProduction")
                {
                    skip = true;
                }
                else
                {
                    skip = false;
                    sb.Append(lhs_sym + " :");
                }
            }

            public override void ExitRhs_sym([NotNull] ScrapeDartParser.Rhs_symContext context)
            {
                if (skip) return;
                if (context.Symbol() != null) sb.Append(" " + context.Symbol().GetText().TrimStart('<').TrimEnd('>'));
                else if (context.ALT() != null) sb.Append(" |");
                else if (context.SL() != null) sb.Append(" " + "'" + context.SL().GetText().TrimStart('`').TrimStart('\''));
                else if (context.DOT() != null) sb.Append(" .");
                else if (context.FUNKY() != null)
                {
                    Dictionary<string, string> map = new Dictionary<string, string>()
                    {
                        { "\\gtilde{}", "~" },
                    };
                    var lit = map.ContainsKey(context.FUNKY().GetText())
                        ? map[context.FUNKY().GetText()]
                        : "'" + context.FUNKY().GetText()
                            .TrimStart('\\')
                            .TrimStart('\\')
                            .TrimEnd('}')
                            .TrimEnd('{')
                            .ToLower() + "'";
                    sb.Append(" " + lit);
                }
                else if (context.STAR() != null) sb.Append("*");
                else if (context.PLUS() != null) sb.Append("+");
                else if (context.QM() != null) sb.Append("?");
            }

            public override void EnterParen([NotNull] ScrapeDartParser.ParenContext context)
            {
                if (skip) return;
                sb.Append(" (");
            }

            public override void ExitParen([NotNull] ScrapeDartParser.ParenContext context)
            {
                if (skip) return;
                sb.Append(" )");
            }

            public override void ExitRrule([NotNull] ScrapeDartParser.RruleContext context)
            {
                if (skip) return;
                sb.AppendLine(" ;");
                sb.AppendLine();
            }
        }
    }
}
