namespace Edory.SharedKernel.CQRS;

/// <summary>
/// Marker-Interface für Commands (CQRS)
/// </summary>
public interface ICommand
{
}

/// <summary>
/// Interface für Commands mit Rückgabewert
/// </summary>
/// <typeparam name="TResult">Typ des Rückgabewerts</typeparam>
public interface ICommand<out TResult> : ICommand
{
}
