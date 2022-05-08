using System.Collections.Generic;
using System.IO;
using System.Linq;
using Antlr4.Runtime;

namespace ScrapeDartSpec
{

    public class Class2 : Lexer
    {
        public Class2(ICharStream input) : base(input)
        {
        }

        public Class2(ICharStream input, TextWriter output, TextWriter errorOutput) : base(input, output, errorOutput)
        {
        }

        public override string[] RuleNames { get; }
        public override string GrammarFileName { get; }
        public override IVocabulary Vocabulary { get; }

        public static int BRACE_NORMAL = 1;
        public static int BRACE_SINGLE = 2;
        public static int BRACE_DOUBLE = 3;
        public static int BRACE_THREE_SINGLE = 4;
        public static int BRACE_THREE_DOUBLE = 5;

        // Enable the parser to handle string interpolations via brace matching.
        // The top of the `braceLevels` stack describes the most recent unmatched
        // '{'. This is needed in order to enable/disable certain lexer rules.
        //
        //   NORMAL: Most recent unmatched '{' was not string literal related.
        //   SINGLE: Most recent unmatched '{' was `'...${`.
        //   DOUBLE: Most recent unmatched '{' was `"...${`.
        //   THREE_SINGLE: Most recent unmatched '{' was `'''...${`.
        //   THREE_DOUBLE: Most recent unmatched '{' was `"""...${`.
        //
        // Access via functions below.
        private Stack<int> braceLevels = new Stack<int>();

        // Whether we are currently in a string literal context, and which one.
        protected bool currentBraceLevel(int braceLevel)
        {
            if (!braceLevels.Any()) return false;
            return braceLevels.Peek() == braceLevel;
        }

        // Use this to indicate that we are now entering a specific '{...}'.
        // Call it after accepting the '{'.
        protected void enterBrace()
        {
            braceLevels.Push(BRACE_NORMAL);
        }
        protected void enterBraceSingleQuote()
        {
            braceLevels.Push(BRACE_SINGLE);
        }
        protected void enterBraceDoubleQuote()
        {
            braceLevels.Push(BRACE_DOUBLE);
        }
        protected void enterBraceThreeSingleQuotes()
        {
            braceLevels.Push(BRACE_THREE_SINGLE);
        }
        protected void enterBraceThreeDoubleQuotes()
        {
            braceLevels.Push(BRACE_THREE_DOUBLE);
        }

        // Use this to indicate that we are now exiting a specific '{...}',
        // no matter which kind. Call it before accepting the '}'.
        protected void exitBrace()
        {
            // We might raise a parse error here if the stack is empty, but the
            // parsing rules should ensure that we get a parse error anyway, and
            // it is not a big problem for the spec parser even if it misinterprets
            // the brace structure of some programs with syntax errors.
            if (braceLevels.Any()) braceLevels.Pop();
        }
    }
}
