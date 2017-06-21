using System;

namespace TestProject
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Testing release notes");
            var line = Console.ReadLine();

            if (line != null && line.Equals("Hei", StringComparison.InvariantCultureIgnoreCase))
            {
                Console.WriteLine("Hei på deg!");
            }

            if (line != null && line.Equals("Ha det", StringComparison.InvariantCultureIgnoreCase))
            {
                Console.WriteLine("Ha det bra!");
            }

            if (line != null && line.Contains("vær"))
            {
                Console.WriteLine("Ja, det er fint vær i dag!");
            }

            Console.ReadLine();
        }
    }
}
