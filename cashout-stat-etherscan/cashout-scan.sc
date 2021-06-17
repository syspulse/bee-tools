import collection.JavaConverters._
import java.time.format._
import java.time._ 

@main
def main( file: String,
    addr:String = Option(System.getenv("ETH_ADDRESS")).getOrElse("0x0000000000000000000000000000000000000001"),
    contract:String = Option(System.getenv("CONTRACT_ADDRESS")).getOrElse("0x0000000000000000000000000000000000000001")) = {

    val ethAddr = addr.toLowerCase()
    val contractAddr = contract.toLowerCase()

    println(s"File: ${file}")
    println(s"Address: ${ethAddr}")
    println(s"Contract: ${contractAddr}")
    
    val csv = scala.io.Source.fromFile(file).getLines.map(s => s.split(",")).drop(1).map(v=>(v(3).substring(1,v(3).size-1).toLowerCase(),v(5).substring(1,v(5).size-1).toDouble)).toSeq
    
    val in =  csv.filter(v=>v._1 != contractAddr && v._1 != ethAddr).map(_._2).sum
    val out = csv.filter(v=>v._1 == contractAddr && v._1 != ethAddr).map(_._2).sum
    
    println(s"In: ${in}")
    println(s"Out: ${out}")
}