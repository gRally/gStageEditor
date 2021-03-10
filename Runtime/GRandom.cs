using System;

public static class GRandom
{
    static Random rnd;

    // Initializes the RNG state with a 32 bit seed
    public static void InitState(int newSeed)
    {
        rnd = new Random(newSeed);
    }

    /// <summary>
    /// Returns a random integer number between /min/ [inclusive] and /max/ [exclusive] (RO).
    /// </summary>
    /// <param name="min"></param>
    /// <param name="max"></param>
    /// <returns></returns>
    public static int Range(int min, int max)
    {
        return rnd.Next(min, max);
    }

    /// <summary>
    /// return true/false depending by percentage
    /// </summary>
    /// <param name="percentage"></param>
    /// <returns></returns>
    public static bool RandomPerc(int percentage)
    {
        return Range(0, 101) < percentage;
    }

    /// <summary>
    /// Returns a random float number between and /min/ [inclusive] and /max/ [inclusive] (RO).
    /// </summary>
    /// <param name="min"></param>
    /// <param name="max"></param>
    /// <returns></returns>
    public static float Range(float min, float max)
    {
        var r = Convert.ToSingle(rnd.NextDouble());
        r *= max - min;
        return r + min;
    }

    public static bool RndBool()
    {
        return Range(0, 2) == 0;
    }
}