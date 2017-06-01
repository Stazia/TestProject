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

            Console.ReadLine();
        }
    }
}
