import sbt.Keys._

//http://stackoverflow.com/questions/28459333/how-to-build-an-uber-jar-fat-jar-using-sbt-within-intellij-idea

lazy val root = (project in file(".")).
  settings(
    name := "Simple_Project",
    version := "0.0.1",
    scalaVersion := "2.10.5",
    mainClass in Compile := Some("Main")
  )

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "1.6.0" % "provided",
  "org.apache.spark" %% "spark-sql" % "1.6.0" % "provided",
  "com.datastax.spark" %% "spark-cassandra-connector" % "1.5.0",
  "com.github.scopt" %% "scopt" % "3.4.0"
//  "com.github.seratch" %% "awscala" % "0.5.+"
)

//required in: https://github.com/scopt/scopt
resolvers += Resolver.sonatypeRepo("public")

// META-INF discarding
assemblyMergeStrategy in assembly := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x => MergeStrategy.last
}

//Required to resolve guava version conflict between spark and spark-cassandra-connector
//see https://goo.gl/7ykqXF
assemblyShadeRules in assembly := Seq(
  ShadeRule.rename("com.google.**" -> "shadeio.@1").inAll
)


