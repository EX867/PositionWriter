package com.karnos.commandscript;
import java.util.ArrayList;
public class MergingTree {
  public Node root;//0th level is root.
  public ArrayList<ArrayList<Node>> levels;
  public MergingTree() {
    root=new Node();
    levels=new ArrayList<ArrayList<Node>>();
    levels.add(new ArrayList<Node>());
    levels.get(0).add(root);
  }
  public void add(Node node, int[] sequence) {//add node to given sequence node. if you want to add node to root, sequence.length is 0.
    //this is really useless operation in most cases, because equals means same object but sometimes not.
    //find equal node.
    boolean found=false;
    if(sequence.length==levels.size()){
      levels.add(new ArrayList<Node>());
    }else{//sequence.length<levels.size()
      for (Node n : levels.get(sequence.length + 1)) {
        if (n.equals(node)) {
          node=n;
          found=true;
          break;
        }
      }
    }
    if(found==false){
      levels.get(sequence.length+1).add(node);
    }
    //add link to it.
    Node parent=root;
    for (int a : sequence) {
      //if(a<0||a>=parent.children.size())//ArrayIndexOut
      parent=parent.children.get(a);
    }
    parent.children.add(node);
  }
  //removing node is not needed for now.
  public static class Node {
    //mergingtree uses equals to remove duplications.
    ArrayList<Node> children;
    public Node() {
      children=new ArrayList<Node>();
    }
  }
}
