namespace ScrapeDartSpec
{
    using Antlr4.Runtime;
    using System;
    using System.Collections.Generic;
    using System.IO;

    public class Class1 : Parser
    {
        static string filePath = null;
        static bool errorHasOccurred = false;
        public override string[] RuleNames => throw new NotImplementedException();

        public override IVocabulary Vocabulary => throw new NotImplementedException();

        public override string GrammarFileName => throw new NotImplementedException();

        /// Must be invoked before the first error is reported for a library.
        /// Will print the name of the library and indicate that it has errors.
        static void prepareForErrors()
        {
            errorHasOccurred = true;
            System.Console.Error.WriteLine("Syntax error in " + filePath + ":");
        }

        /// Parse library, return true if success, false if errors occurred.
        public bool parseLibrary(String fp)
        {
            filePath = fp;
            errorHasOccurred = false;
            //libraryDefinition();
            return !errorHasOccurred;
        }

        // Enable the parser to treat AWAIT/YIELD as keywords in the body of an
        // `async`, `async*`, or `sync*` function. Access via methods below.
        private Stack<bool> asyncEtcAreKeywords = new Stack<bool>();


        public Class1(ITokenStream input, TextWriter output, TextWriter errorOutput) : base(input, output, errorOutput)
        {
            asyncEtcAreKeywords.Push(false);
        }

        // Use this to indicate that we are now entering an `async`, `async*`,
        // or `sync*` function.
        void startAsyncFunction() { asyncEtcAreKeywords.Push(true); }

        // Use this to indicate that we are now entering a function which is
        // neither `async`, `async*`, nor `sync*`.
        void startNonAsyncFunction() { asyncEtcAreKeywords.Push(false); }

        // Use this to indicate that we are now leaving any funciton.
        void endFunction() { asyncEtcAreKeywords.Pop(); }

        // Whether we can recognize AWAIT/YIELD as an identifier/typeIdentifier.
        bool asyncEtcPredicate(int tokenId)
        {
            if (tokenId == NewDart2Lexer.AWAIT || tokenId == NewDart2Lexer.YIELD)
            {
                return !asyncEtcAreKeywords.Peek();
            }
            return false;
        }

        protected bool checkAsyncEtcPredicate()
        {
            return asyncEtcPredicate(this.CurrentToken.Type);
        }
    }
}