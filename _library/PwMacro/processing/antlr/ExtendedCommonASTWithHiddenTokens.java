package antlr;

/* ANTLR Translator Generator
 * Project led by Terence Parr at http://www.jGuru.com
 * Software rights: http://www.antlr.org/RIGHTS.html
 *
 * $Id$
 */
import antlr.collections.AST;

import java.io.IOException;
import java.io.Writer;
/** A CommonAST whose initialization copies hidden token
 *  information from the Token used to create a node.
 */
public class ExtendedCommonASTWithHiddenTokens 
    extends CommonASTWithHiddenTokens {

    public ExtendedCommonASTWithHiddenTokens() {
        super();
    }

    public ExtendedCommonASTWithHiddenTokens(Token tok) {
        super(tok);
    }

    public void initialize(AST ast) {
        ExtendedCommonASTWithHiddenTokens a =
	    (ExtendedCommonASTWithHiddenTokens)ast;
        super.initialize(a);
        hiddenBefore = a.getHiddenBefore();
        hiddenAfter = a.getHiddenAfter();
    }

    public String getHiddenAfterString() {

	CommonHiddenStreamToken t;
	StringBuilder hiddenAfterString = new StringBuilder(100);

	for ( t = hiddenAfter ; t != null ; t = t.getHiddenAfter() ) {
	    hiddenAfterString.append(t.getText());
	}

	return hiddenAfterString.toString();
    }

    public String getHiddenBeforeString() {

	CommonHiddenStreamToken
	    child = null,
	    parent = hiddenBefore;

	// if there aren't any hidden tokens here, quietly return
	// 
	if (parent == null) {
	    return "";
	}

	// traverse back to the head of the list of tokens before this node
	do {
	    child = parent;
	    parent = child.getHiddenBefore();
	} while (parent != null);

	// dump that list

	StringBuilder hiddenBeforeString = new StringBuilder(100);

	for ( CommonHiddenStreamToken t = child; t != null ; 
	      t = t.getHiddenAfter() ) {
	    hiddenBeforeString.append(t.getText());
	}

	return hiddenBeforeString.toString();
    }

    public void xmlSerializeNode(Writer out) throws IOException {
        StringBuilder sb = new StringBuilder(100);
        sb.append("<");
        sb.append(getClass().getName() + " ");

        sb.append("hiddenBeforeString=\"" +
            encode(getHiddenBeforeString()) +
            "\" text=\"" + encode(getText()) + "\" type=\"" +
            getType() + "\" hiddenAfterString=\"" +
            encode(getHiddenAfterString()) + "\"/>");
        out.write(sb.toString());
    }

    public void xmlSerializeRootOpen(Writer out) throws IOException {
        StringBuilder sb = new StringBuilder(100);
        sb.append("<");
        sb.append(getClass().getName() + " ");
        sb.append("hiddenBeforeString=\"" +
            encode(getHiddenBeforeString()) +
            "\" text=\"" + encode(getText()) + "\" type=\"" +
            getType() + "\" hiddenAfterString=\"" +
            encode(getHiddenAfterString()) + "\">\n");
        out.write(sb.toString());
    }

    public void xmlSerializeRootClose(Writer out)
        throws IOException {
        out.write("</" + getClass().getName() + ">\n");
    }

    public void xmlSerialize(Writer out) throws IOException {
        // print out this node and all siblings
        for (AST node = this;
             node != null;
             node = node.getNextSibling()) {
            if (node.getFirstChild() == null) {
                // print guts (class name, attributes)
                ((BaseAST)node).xmlSerializeNode(out);
            }
            else {
                ((BaseAST)node).xmlSerializeRootOpen(out);

                // print children
                ((BaseAST)node.getFirstChild()).xmlSerialize(out);

                // print end tag
                ((BaseAST)node).xmlSerializeRootClose(out);
            }
        }
    }

}
