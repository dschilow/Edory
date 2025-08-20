namespace Edory.SharedKernel.CQRS;

/// <summary>
/// Interface für Queries (CQRS)
/// </summary>
/// <typeparam name="TResult">Typ des Rückgabewerts</typeparam>
public interface IQuery<out TResult>
{
}
