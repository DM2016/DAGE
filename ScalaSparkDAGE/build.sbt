//http://stackoverflow.com/questions/28459333/how-to-build-an-uber-jar-fat-jar-using-sbt-within-intellij-idea

lazy val root = (project in file(".")).
  settings(
    name := "Simple_Project",
    version := "1.0",
    scalaVersion := "2.10.5",
    mainClass in Compile := Some("Main")
  )

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "1.6.0" % "provided",
  "org.apache.spark" %% "spark-sql" % "1.6.0" % "provided",
  "com.datastax.spark" %% "spark-cassandra-connector" % "1.5.0"
)

// META-INF discarding
assemblyMergeStrategy in assembly := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x => MergeStrategy.first
}




