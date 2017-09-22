void setup() {
  if (args==null)System.exit(1);
  if (args.length!=2)System.exit(1);
  PrintWriter write=createWriter(args[0]);
  write.write(args[1]);
  write.flush();
  write.close();
  exit();
}