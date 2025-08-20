using System.Threading;
using System.Threading.Tasks;

namespace Edory.SharedKernel.CQRS;

/// <summary>
/// Interface für Command Handler ohne Rückgabewert
/// </summary>
/// <typeparam name="TCommand">Typ des Commands</typeparam>
public interface ICommandHandler<in TCommand>
    where TCommand : class, ICommand
{
    Task HandleAsync(TCommand command, CancellationToken cancellationToken = default);
}

/// <summary>
/// Interface für Command Handler mit Rückgabewert
/// </summary>
/// <typeparam name="TCommand">Typ des Commands</typeparam>
/// <typeparam name="TResult">Typ des Rückgabewerts</typeparam>
public interface ICommandHandler<in TCommand, TResult>
    where TCommand : class, ICommand<TResult>
{
    Task<TResult> HandleAsync(TCommand command, CancellationToken cancellationToken = default);
}
